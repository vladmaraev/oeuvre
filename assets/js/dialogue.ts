import { Socket } from "phoenix";

import { assign, createActor, setup, fromPromise } from "xstate";

import { Hypothesis, speechstate, SpeechStateExternalEvent } from "speechstate";
import { setupRecorders } from "./signalling2";

const settings = {
  azureCredentials: "azureToken",
  azureRegion: "swedencentral",
  asrDefaultCompleteTimeout: 0,
  asrDefaultNoInputTimeout: 10000,
  locale: "en-GB",
  ttsDefaultVoice: "en-GB-RyanNeural",
};

interface SetupParam {
  image64: string;
  session_id: number;
  step: number;
  prolific_pid: string;
  condition: string;
}

interface Move {
  role: "assistant" | "user";
  content: string;
}

const sorry_laughter_utterance = `<s /><mstts:express-as style="chat">Sorry </mstts:express-as><s /><mstts:express-as style="chat"><prosody volume="+30.00%" pitch="+10.00%" contour="(89%, +95%)"><phoneme alphabet="ipa" ph="h.">haha</phoneme></prosody></mstts:express-as><s /><mstts:express-as style="chat"><phoneme alphabet="ipa" ph="h">h</phoneme></mstts:express-as><s />. `;

const sorry_utterance = `<s /><mstts:express-as style="chat">Sorry </mstts:express-as><s />. `;

const signallingId = document
  .getElementById("container")!
  .getAttribute("data-signalling-id");

const dmMachine = setup({
  actors: {
    setupRecording: fromPromise<any, null>(() => {
      return setupRecorders();
    }),
    saveTranscript: fromPromise<
      any,
      { session_id: number; moves: Move[]; step: number }
    >(async ({ input }) => {
      const response = await fetch("session/savetranscript", {
        headers: {
          "Content-Type": "application/json",
        },
        method: "POST",
        body: JSON.stringify(input),
      });
      return response.json();
    }),
    callGpt: fromPromise<
      any,
      { description: string; history: Move[]; condition: string }
    >(async ({ input }) => {
      const response = await fetch("ollama/chat", {
        headers: {
          "Content-Type": "application/json",
        },
        method: "POST",
        body: JSON.stringify({
          ...input,
          ...{ signalling_id: signallingId },
        }),
      });
      return response.json();
    }),
    callVLM: fromPromise<any, { image: string }>(async ({ input }) => {
      const params = new URLSearchParams();
      params.append("image", input.image);
      const response = await fetch(`ollama/describe`, {
        headers: {
          "Content-Type": "application/json",
        },
        method: "POST",
        body: JSON.stringify(input),
      });
      return response.json();
    }),
  },
  actions: {
    /** stop recording */
    stop_recording: ({ context }) => {
      context.recordingSockets?.forEach((s) => {
        s.disconnect();
      });
      context.recordingPCs?.forEach((pc) =>
        pc.getSenders().forEach((sender) => sender.track?.stop()),
      );
    },

    /** speak and listen */
    "spst.speak": ({ context }, params: { utterance: string }) =>
      context.ssRef.send({
        type: "SPEAK",
        value: {
          utterance: params.utterance,
        },
      }),

    speak_greeting: ({ context }) => {
      context.ssRef.send({
        type: "SPEAK",
        value: {
          utterance: context.is.moves[0].content,
        },
      });
    },
    speak_moveon: ({ context }) =>
      context.ssRef.send({
        type: "SPEAK",
        value: {
          utterance:
            (context.condition === "1"
              ? sorry_laughter_utterance
              : sorry_utterance) +
            `It seems our time for discussion is up. ` +
            (context.step !== 1
              ? `Please fill and submit the survey. `
              : `Make sure you have filled the form this time too. We will then redirect you to the final survey. Hope you have a truly great day!`),
        },
      }),
    speak_bye: ({ context }) => {
      context.ssRef.send({
        type: "SPEAK",
        value: {
          utterance:
            "Sorry! It seems our time for discussion is up. Make sure you have filled the form this time too. We will redirect you to the final survey. Hope you have a truly great day!",
        },
      });
    },

    speak_stream: ({ context }) => {
      context.ssRef.send({
        type: "SPEAK",
        value: {
          utterance: "",
          stream: `sse?signalling_id=${signallingId}`,
        },
      });
    },
    listen: ({ context }) =>
      context.ssRef.send({
        type: "LISTEN",
        value: { noInputTimeout: 6000 },
      }),
    control: ({ context }) =>
      context.ssRef.send({
        type: "CONTROL",
      }),

    /** update rules */
    enqueue_recognition_result: assign(({ context, event }) => {
      const utterance = (event as any).value[0].utterance;
      const newIS = {
        ...context.is,
        moves: [
          ...context.is.moves,
          {
            role: "user",
            content: utterance,
          },
        ] as any,
      };
      console.log("[IS enqueue_recognition_result]", newIS);
      return { is: newIS };
    }),
    enqueue_input_timeout: assign(({ context }) => {
      const utterance =
        "(the user is not saying anything or you can't hear them)";
      const newIS = {
        ...context.is,
        moves: [
          ...context.is.moves,
          {
            role: "user",
            content: utterance,
          },
        ] as any, // FIXME
      };
      console.log("[IS enqueue_input_timeout]", newIS);
      return { is: newIS };
    }),
    enqueue_assistant_move: assign(({ context, event }) => {
      const move = (event as any).output;
      console.log("[IS enqueue_assistant_move]", move);
      const newIS = {
        ...context.is,
        moves: [...context.is.moves, (event as any).output],
      } as any;
      console.log("[IS enqueue_assistant_move]", newIS);
      return { is: newIS };
    }),
  },
  delays: {
    TOTAL_TIMEOUT: 300_000,
  },
  types: {} as {
    context: {
      ssRef?: any;
      is: {
        input: string[];
        moves: Move[];
      };
      session_id?: number;
      step?: number;
      image64?: string;
      imageDescription?: string;
      surveyFilled: boolean;
      micTested: boolean;
      lastResult?: Hypothesis[];
      recordingPCs?: RTCPeerConnection[];
      recordingSockets?: Socket[];
      condition?: string;
      prolific_pid?: string;
    };
    events:
      | SpeechStateExternalEvent
      | {
          type: "SETUP";
          value: SetupParam;
        }
      | { type: "CLICK" }
      | { type: "SURVEY_NEXT" };
  },
}).createMachine({
  context: ({ spawn }) => ({
    ssRef: spawn(speechstate, { input: settings }),
    surveyFilled: false,
    micTested: false,
    is: {
      input: [],
      moves: [
        {
          role: "assistant",
          content: "We have five minutes to discuss it. Let's get started!",
        },
      ],
      image: "",
    },
  }),
  id: "DM",
  initial: "SetupRecording",
  on: {
    SETUP: {
      actions: assign(({ event }) => ({
        image64: event.value.image64,
        session_id: event.value.session_id,
        prolific_pid: event.value.prolific_pid,
        step: event.value.step,
        condition: event.value.condition,
      })),
    },
    SURVEY_NEXT: {
      actions: assign({ surveyFilled: true }),
    },
  },
  states: {
    SetupRecording: {
      meta: {
        view: "prepare",
      },
      invoke: {
        src: "setupRecording",
        input: null,
        onDone: {
          target: "Prepare",
          actions: assign(({ event }) => ({
            recordingPCs: event.output.pcs,
            recordingSockets: event.output.sockets,
          })),
        },
      },
    },
    Prepare: {
      meta: {
        view: "prepare",
      },
      entry: [({ context }) => context.ssRef.send({ type: "PREPARE" })],
      on: { ASRTTS_READY: "Ready" },
    },

    Ready: {
      entry: ({ context }) => console.log(context),
      meta: {
        view: "ready",
      },
      on: {
        CLICK: "Main",
      },
    },
    Main: {
      on: { CLICK: { actions: "control" } },
      initial: "TestMic",
      states: {
        TestMic: {
          initial: "Greet",
          on: {
            LISTEN_COMPLETE: [
              {
                target: "MicTested",
                guard: ({ context }) => !!context.lastResult,
              },
              { target: ".NoInput" },
            ],
          },
          states: {
            Greet: {
              entry: ({ context }) => {
                context.ssRef.send({
                  type: "SPEAK",
                  value: {
                    utterance:
                      "Hello and welcome! In a moment you will be shown a work of art that you will need to discuss with me. But to get started, we need to make sure that I can hear you. And can you hear me? ",
                  },
                });
              },
              on: { SPEAK_COMPLETE: "Ask" },
            },
            NoInput: {
              entry: {
                type: "spst.speak",
                params: {
                  utterance: `I can't hear you! Please say something.`,
                },
              },
              on: { SPEAK_COMPLETE: "Ask" },
            },
            Ask: {
              entry: "listen",
              on: {
                RECOGNISED: {
                  actions: assign(({ event }) => {
                    return { lastResult: event.value };
                  }),
                },
                ASR_NOINPUT: {
                  actions: assign({ lastResult: undefined }),
                },
              },
            },
          },
        },
        MicTested: {
          entry: {
            type: "spst.speak",
            params: {
              utterance: `That's wonderful! Now to the work of art. Let's see...`,
            },
          },
          on: { SPEAK_COMPLETE: "GetDescription" },
        },
        GetDescription: {
          entry: () => (document.getElementById("image")!.hidden = false),
          invoke: {
            src: "callVLM",
            input: ({ context }) => ({
              image: context.image64!,
            }),
            onDone: {
              actions: assign(({ event }) => ({
                imageDescription: event.output.description,
              })),
              target: "DelayApology",
            },
          },
        },
        DelayApology: {
          initial: "Apology",
          states: {
            Apology: {
              entry: ({ context }) =>
                context.ssRef.send({
                  type: "SPEAK",
                  value: {
                    utterance:
                      context.condition === "1"
                        ? sorry_laughter_utterance
                        : sorry_utterance,
                  },
                }),
              on: { SPEAK_COMPLETE: "MaybeDownplayer" },
            },
            MaybeDownplayer: {
              entry: ({ context }) =>
                context.ssRef.send({
                  type: "LISTEN",
                  value: {
                    noInputTimeout: 300,
                  },
                }),
              on: { LISTEN_COMPLETE: "Reason" },
            },
            Reason: {
              entry: {
                type: "spst.speak",
                params: {
                  utterance: "It took a moment for me.",
                },
              },
              on: { SPEAK_COMPLETE: "Fin" },
            },
            Fin: { type: "final" },
          },
          onDone: { target: "Greeting" },
        },
        Greeting: {
          entry: ["speak_greeting"],
          on: { SPEAK_COMPLETE: { target: "Ask" } },
        },
        Ask: {
          entry: "listen",
          on: {
            RECOGNISED: {
              actions: { type: "enqueue_recognition_result" },
            },
            ASR_NOINPUT: {
              actions: { type: "enqueue_input_timeout" },
            },
            LISTEN_COMPLETE: {
              target: "Respond",
            },
          },
        },
        Respond: {
          type: "parallel",
          RECOGNISED: {
            actions: { type: "enqueue_recognition_result" },
          },
          ASR_NOINPUT: {
            actions: { type: "enqueue_input_timeout" },
          },
          LISTEN_COMPLETE: {
            target: "Respond",
            reenter: true,
          },
          states: {
            CallGpt: {
              initial: "Calling",
              states: {
                Calling: {
                  invoke: {
                    src: "callGpt",
                    input: ({ context }) => ({
                      description: context.imageDescription!,
                      history: context.is.moves,
                      condition: context.condition!,
                    }),
                    onDone: {
                      actions: "enqueue_assistant_move",
                      target: "Called",
                    },
                  },
                },
                Called: { type: "final" },
              },
            },
            Speak: {
              initial: "Speaking",
              states: {
                Speaking: {
                  entry: { type: "speak_stream" },
                  on: { SPEAK_COMPLETE: "Spoken" },
                },
                Spoken: { type: "final" },
              },
            },
          },
          onDone: "Ask",
        },
      },
      after: { TOTAL_TIMEOUT: "Expired" },
    },
    Expired: {
      initial: "Wait",
      states: {
        Wait: {
          on: {
            SPEAK_COMPLETE: "MoveOn",
            LISTEN_COMPLETE: "MoveOn",
          },
          after: {
            10_000: "MoveOn",
          },
        },
        MoveOn: {
          meta: {
            view: "speaking",
          },
          entry: { type: "speak_moveon" },
          on: { SPEAK_COMPLETE: "SaveTranscript" },
        },
        SaveTranscript: {
          entry: ({ context }) => console.log(context),
          invoke: {
            src: "saveTranscript",
            input: ({ context }) => ({
              session_id: context.session_id!,
              step: context.step!,
              moves: context.is.moves,
            }),
            onDone: { target: "Next" },
          },
        },
        Next: {
          entry: [
            { type: "stop_recording" },
            () => (document.getElementById("survey")!.hidden = false),
            () => (document.getElementById("container")!.hidden = true),
          ],
          meta: {
            view: "expired",
          },
          always: [
            {
              target: "#DM.Done",
              guard: ({ context }) => context.surveyFilled,
            },
          ],
        },
      },
    },
    Done: {
      meta: {
        view: "done",
      },
      entry: () =>
        (window.location.pathname =
          window.location.pathname === "/"
            ? "/nextstep"
            : window.location.pathname + "nextstep"),
      type: "final",
    },
  },
});

export const dmActor = createActor(dmMachine, {
  // inspect: inspector.inspect,
});

export function startSpeechState(param: SetupParam) {
  dmActor.start();
  console.debug("Sending setup with ", param);
  dmActor.send({
    type: "SETUP",
    value: param,
  });
  window.addEventListener("message", (e) => {
    if (e.data === "SURVEY_NEXT") {
      console.debug("received SURVEY_NEXT event");
      dmActor.send({ type: "SURVEY_NEXT" });
    }
  });
}
