import java.lang.Math.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT fft;
int fftSize;

void setup()
{
    size(1024, 480, P2D);
    colorMode(HSB, 360, 100, 100, 100);

    minim = new Minim(this);

    fftSize = 512;
    player = minim.loadFile("../Heartless Solution -To The Worthless Destination-.mp3", fftSize);
    
    player.play();

    fft = new FFT(player.bufferSize(), player.sampleRate());
}


void draw()
{
    background(0);
    strokeWeight(2.0);

    fft.forward( player.mix );

    for (int i = 0; i < fft.specSize(); i++)
    {
        float x = map(i, 0, fft.specSize(), 0, width);
        float y = map(fft.getBand(i), 0, 5.0, height, 0);
        float h = map(i, 0, fft.specSize(), 0, 180);
        
        stroke(h, 100, 100);
        line(x, height, x, y);
    }
}


void stop()
{
    player.close();
    minim.stop();
    super.stop();
}