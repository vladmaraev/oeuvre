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
    const socket = new Socket("/signalling", {
      params: {
        token: (window as any).userToken,
      },
    });
    socket.connect();
    let egressChannel = socket.channel(`${signallingId}_${suffix}`);
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
  channel: Channel,
  topic: string,
  socket: Socket,
  mode: string,
) => {
  return new Promise((resolve, _reject) => {
    console.debug("Starting egress connection...", channel, topic, socket);
    channel.on(topic, async (payload) => {
      const { type, data } = payload;
      switch (type) {
        case "sdp_answer":
          console.log("Received SDP answer:", data);
          await pc.setRemoteDescription(data);
          break;
        case "ice_candidate":
          console.log("Received ICE candidate:", data);
          await pc.addIceCandidate(data);
          break;
      }
    });

    const pc = new RTCPeerConnection(pcConfig);
    pc.addTransceiver("audio");
    if (mode == "a+v") pc.addTransceiver("video");

    pc.onicecandidate = (event) => {
      if (event.candidate === null) return;
      console.debug("Sent ICE candidate:", event.candidate);
      channel.push(
        topic,
        JSON.stringify({
          type: "ice_candidate",
          data: event.candidate,
        }) as any,
      );
    };

    pc.onnegotiationneeded = (_event) => {
      console.debug("Negotiation needed!", pc.getSenders());
      pc.createOffer().then((offer) => {
        pc.setLocalDescription(offer);
        console.debug("Ready to negotiate the offer", offer);
        channel.push(
          topic,
          JSON.stringify({ type: "sdp_offer", data: offer }) as any,
        );
      });
    };

    pc.onconnectionstatechange = (_event) => {
      if (pc.connectionState == "connected") {
        // return resolve(pc);
        console.debug("connected!");
      }
    };

    mode == "a+v"
      ? replaceWithDisplayMedia(pc).then(() => resolve(pc))
      : replaceWithUserMedia(pc).then(() => resolve(pc));
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
