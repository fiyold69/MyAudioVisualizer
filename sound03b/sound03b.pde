import java.lang.Math.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer player;
FFT fft;
int fftSize;
int j = 0;



void setup()
{
    size(1024, 480, P2D);
    colorMode(HSB, 360, 100, 100, 100);

    minim = new Minim(this);

    fftSize = 1024;
    player = minim.loadFile("../Heartless Solution -To The Worthless Destination-.mp3", fftSize);

    player.play();

    fft = new FFT(player.bufferSize(), player.sampleRate());
}


void draw()
{
    background(0);
    strokeWeight(2.0);

    fft.forward( player.mix );


    float minHz = 20;
    float maxHz = player.sampleRate() / 2;

    for (int i = 0; i < fft.specSize(); i++)
    {
        float hz = fft.indexToFreq(i);

        if (j == 0) {
            println(hz);
        }

        if (hz < minHz) continue;

        float x = map(log(hz) / log(10), log(minHz) / log(10), log(maxHz) / log(10), 0, width);

        float amp = fft.getBand(i);
        float y = map(amp, 0, 30.0, height, 0);

        float h = map(log(hz) / log(10), log(minHz) / log(10), log(maxHz) / log(10), 0, 240);

        stroke(h, 80, 100);
        line(x, height + 100, x, y);
    }
    
    j++;
}


void mousePressed()
{
    if ( player.isPlaying() ) {
        player.pause();
    } else {
        player.play();
    }
}


void stop()
{
    player.close();
    minim.stop();
    super.stop();
}
