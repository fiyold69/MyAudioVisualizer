import java.lang.Math.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer player;
FFT fft;
int fftSize;
float zoff = 0;



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
    fill(0, 20); // 20 is the Transparency
    rect(0, 0, width, height);

    fft.forward( player.mix );


    // 1. 低音成分（エネルギー）の抽出（150Hz以下を合算）
    float bassEnergy = 0;
    int lowEndIndex = fft.freqToIndex(100);
    for (int i = 0; i <= lowEndIndex; i++) {
        bassEnergy += fft.getBand(i);
    }

    // println(bassEnergy);

    // 2. 描画の設定
    stroke(255, 50); // Grid line is semi-transparent
    noFill(); 

    float scl = 20; // the size of Grid
    int cols = width / (int)(scl - 1);
    int rows = height / (int)scl;

    // 3. 地形（terrain）の描画
    // connect width lines
    for (int y = 0; y < rows; y++) {
        beginShape();
        for (int x = 0; x < cols; x++) {
            // adjust Noise Parameter
            // increasing bassEnergy, the SWELL of the noise is getting stronger
            float factor = 10; // the Pixelation (Roughness of Grid)
            float noiseVal = noise(x * factor, y * factor, zoff);

            // the height of terrain = 
            //      Basic Fluctuation + Explosive Surge caused by Bass
            float peak = map(bassEnergy, 0, 10, 10, 300);
            float dy = noiseVal * peak;

            println(dy);

            // calculate Coordinate
            float px = x * scl;
            float py = y * scl - dy + height / 2; // Placed near the center of the screen

            // color adjustment : The higher the value, the brighter the color shifts from Blue to red
            stroke(map(dy, 0, 200, 180, 360), 80, 100, 150);

            vertex(px, py);
        }
        endShape();
    }

    // 4. 時間を進める（低音に合わせて「震え」の速さを変える）
    zoff += map(bassEnergy, 0, 100, 0.01, 0.08);
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
