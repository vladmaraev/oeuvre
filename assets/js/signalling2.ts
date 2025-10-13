import { Channel, Socket } from "phoenix";

const pcConfig = { iceServers: [{ urls: "stun:stun.l.google.com:19302" }] };
const mediaConstraints = { video: false, audio: true };
const displayMediaOptions = {
  video: {
    displaySurface: "browser",
  },
  audio: true,
  preferCurrentTab: true,
  selfBrowserSurface: "include",
  systemAudio: "include",
  surfaceSwitching: "include",
  monitorTypeSurfaces: "include",
};

type SetupRecorders = () => Promise<{
  pcs: RTCPeerConnection[];
  sockets: Socket[];
}>;
export const setupRecorders: SetupRecorders = () =>
  new Promise(async (resolve, _reject) => {
    const recorders = [
      await connect("egress_screen", "a+v"),
      await connect("egress_mic", "a"),
    ];
    // const senders = [pc1.getSenders(), pc2.getSenders()].flat();
    // const tracks = senders.map((s) => s.track);
    // console.debug("senders,tracks:", senders, tracks);
    resolve({
      pcs: recorders.map((r) => r.pc),
      sockets: recorders.map((r) => r.socket),
    });
  });

type Connect = (
  suffix: string,
  mode: string,
) => Promise<{ pc: RTCPeerConnection; socket: Socket }>;
const connect: Connect = (suffix, mode) => {
  return new Promise(async (resolve, reject) => {
    const socket = new Socket("signalling", {
      params: {
        token: (window as any).userToken,
      },
    });
    socket.connect();
    let egressChannel = socket.channel(`${signallingId}_${suffix}`);
    console.debug(
      "Joining egress signaling socket...",
      socket,
      egressChannel,
      `${signallingId}_${suffix}`,
    );
    egressChannel
      .join()
      .receive("ok", async (resp) => {
        console.debug("Joined successfully to egress signaling socket", resp);
        const pc = await startEgressConnection(
          egressChannel,
          `${signallingId}_${suffix}`,
          socket,
          mode,
        );
        resolve({ pc: pc, socket: socket });
      })
      .receive("error", (resp) => {
        console.debug("Unable to join egress signaling socket", resp);
        reject();
      });
  });
};

type StartEgressConnection = (
  channel: Channel,
  topic: string,
  socket: Socket,
  mode: string,
) => Promise<RTCPeerConnection>;
const startEgressConnection: StartEgressConnection = async (
  channel,
  topic,
  socket,
  mode,
) => {
  return new Promise(async (resolve) => {
    const pc = new RTCPeerConnection(pcConfig);

    // Phoenix inbound
    channel.on(topic, async ({ type, data }) => {
      if (type === "sdp_answer") {
        await pc.setRemoteDescription(data);
      } else if (type === "ice_candidate") {
        await pc.addIceCandidate(data);
      }
    });

    // Prefer H.264 for video (packetization-mode=1)
    const aTrans = pc.addTransceiver("audio", { direction: "sendonly" });
    const vTrans =
      mode === "a+v"
        ? pc.addTransceiver("video", { direction: "sendonly" })
        : undefined;
    if (vTrans) {
      const all = RTCRtpSender.getCapabilities("video")?.codecs || [];
      const h264 = all.filter(
        (c) =>
          c.mimeType.toLowerCase() === "video/h264" &&
          (c.sdpFmtpLine || "").toLowerCase().includes("packetization-mode=1"),
      );
      if (h264.length) vTrans.setCodecPreferences(h264);
    }

    pc.onicecandidate = (e) => {
      if (!e.candidate) return;
      channel.push(
        topic,
        JSON.stringify({ type: "ice_candidate", data: e.candidate }) as any,
      );
    };

    pc.onconnectionstatechange = () => {
      if (pc.connectionState === "connected") {
        const vSender = pc
          .getSenders()
          .find((s) => s.track && s.track.kind === "video");
        (vSender as any)?.requestKeyFrame?.(); // force an IDR ASAP
        console.debug("connected!");
      }
    };

    // Attach media, then make the *first* offer once
    async function primeTracksAndOffer() {
      if (mode === "a+v") {
        const ms =
          await navigator.mediaDevices.getDisplayMedia(displayMediaOptions);
        ms.getVideoTracks().forEach((t) => (t.contentHint = "detail"));

        const senders = pc.getSenders();
        const aSender =
          senders.find((s) => s.track?.kind === "audio") || senders[0];
        const vSender =
          senders.find((s) => s.track?.kind === "video") ||
          senders.find((s) => s !== aSender);

        for (const t of ms.getTracks()) {
          const s = t.kind === "audio" ? aSender : vSender;
          if (s) await s.replaceTrack(t);
        }
      } else {
        const ms = await navigator.mediaDevices.getUserMedia({
          video: false,
          audio: true,
        });
        const aSender =
          pc.getSenders().find((s) => s.track?.kind === "audio") ||
          pc.getSenders()[0];
        await aSender.replaceTrack(ms.getAudioTracks()[0]);
      }

      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      channel.push(
        topic,
        JSON.stringify({ type: "sdp_offer", data: offer }) as any,
      );
      resolve(pc);
    }

    await primeTracksAndOffer();
  });
};

const replaceWithDisplayMedia = async (
  pc: RTCPeerConnection,
): Promise<MediaStreamTrack | void> => {
  return navigator.mediaDevices
    .getDisplayMedia(displayMediaOptions)
    .then((mediaStream) =>
      mediaStream.getTracks().forEach((track) => {
        if (track.kind === "audio") {
          pc.getSenders()[0].replaceTrack(track);
        } else {
          pc.getSenders()[1].replaceTrack(track);
        }
      }),
    );
};

const replaceWithUserMedia = async (
  pc: RTCPeerConnection,
): Promise<MediaStreamTrack | void> => {
  return navigator.mediaDevices
    .getUserMedia(mediaConstraints)
    .then((mediaStream) =>
      mediaStream.getTracks().forEach((track) => {
        if (track.kind === "audio") {
          pc.getSenders()[0].replaceTrack(track);
        }
      }),
    );
};

// let connStatus = document.getElementById("status")!;
// const button = document.getElementById("button")!;
// button.onclick = () => {
//   connect("egress_screen", "a+v");
//   connect("egress_mic", "a");
// };

const signallingId = document
  .getElementById("container")!
  .getAttribute("data-signalling-id");
