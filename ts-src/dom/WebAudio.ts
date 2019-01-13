// sets up Web Audio

import { Maybe } from "tsmonad";

interface IAudioBuffer {
  name: string;
  buffer: AudioBuffer;
}

export class WebAudio {
  public audioReady: boolean = false;

  protected audioContext: AudioContext;
  protected output: AudioNode;
  protected audioBuffers = {}; // object containing a buffer for each game sound

  protected soundPaths = [
    "bright-bell",
    "pop",
    "soft-bell",
    "warp",
    "thud",
    "woo",
    "crate-smash",
    "switch",
    "power-up",
    "bounce"
  ];

  public init() {
    this.audioContext = this.createAudioContext(); // create audioContext
    this.output = this.createLimiter(this.audioContext); // create limiter and link up

    const promises = this.fetchSounds(this.soundPaths);

    Promise.all(promises).then(buffers => {
      this.audioReady = true;
    });
  }

  public fetchSounds(soundPaths: string[]): Array<Promise<AudioBuffer>> {
    return soundPaths.map(soundName => {
      const path = this.getSoundPath(soundName);
      return this.loadBuffer(soundName, path);
    });
  }

  public createAudioContext(): AudioContext {
    if (this.audioContext) {
      return this.audioContext;
    }
    return new ((window as any).AudioContext ||
      (window as any).webkitAudioContext)();
  }

  public createLimiter(audioCtx) {
    // Create a compressor node
    const compressor = audioCtx.createDynamicsCompressor();
    compressor.threshold.value = -1;
    compressor.knee.value = 40;
    compressor.ratio.value = 12;
    compressor.attack.value = 0;
    compressor.release.value = 0.25;
    compressor.connect(audioCtx.destination);

    return compressor;
  }

  public playSound(soundName: string, pan: number) {
    if (!this.audioReady) {
      return false;
    }
    this.getAudioNode(soundName, pan).caseOf({
      just: audioNode => audioNode.start(),
      nothing: () => {
        // 
      }
    });
  }

  public getAudioNode(
    soundName: string,
    pan: number
  ): Maybe<AudioBufferSourceNode> {
    const audioBuffer = (Object as any)
      .values(this.audioBuffers)
      .find(name => name.name === soundName);
    if (audioBuffer) {
      return Maybe.just(this.createOutput(audioBuffer, pan));
    }
    return Maybe.nothing();
  }

  public getSoundPath(soundName: string) {
    return "/sounds/" + soundName + ".wav";
  }

  public createOutput(
    buffer: IAudioBuffer,
    pan: number
  ): AudioBufferSourceNode {
    const panner = this.audioContext.createStereoPanner();
    panner.connect(this.output);
    panner.pan.value = pan;

    const source = this.audioContext.createBufferSource();
    source.buffer = buffer.buffer;
    source.connect(panner);

    return source;
  }

  public storeBuffer(soundName: string, buffer): IAudioBuffer {
    const audioBuffer = {
      name: soundName,
      buffer
    };
    return (this.audioBuffers[soundName] = audioBuffer);
  }

  public loadBuffer(soundName: string, url: string): Promise<AudioBuffer> {
    return new Promise((resolve, reject) => {
      const request = new XMLHttpRequest();
      request.open("GET", url, true);
      request.responseType = "arraybuffer";

      request.onload = () => {
        this.audioContext.decodeAudioData(
          request.response,
          buffer => {
            if (!buffer) {
              reject("Buffer could not be read!");
            }
            this.storeBuffer(soundName, buffer);
            resolve(buffer);
          },
          error => {
            reject(error);
          }
        );
      };

      request.onerror = () => {
        reject("BufferLoader: XHR error");
      };

      request.send();
    });
  }
}
