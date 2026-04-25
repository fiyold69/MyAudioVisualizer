import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer player;
FFT fft;
ArrayList<Particle> particles = new ArrayList<Particle>();

int threshold = 70;


void setup()
{
    size(1024, 480, P2D);
    colorMode(HSB, 360, 100, 100, 100);

    minim = new Minim(this);

    int fftSize = 1024;
    player = minim.loadFile("../Heartless Solution -To The Worthless Destination-.mp3", fftSize);

    player.play();

    fft = new FFT(player.bufferSize(), player.sampleRate());
}


void draw()
{
    background(0);

    fft.forward( player.mix );


    // 1. Extract high-frequency energy
    float hiEndHz = 3000;
    int hiStartIndex = fft.freqToIndex(hiEndHz);
    float hiEnergy = 0;
    for (int i = hiStartIndex; i < fft.specSize(); i++) {
        hiEnergy += fft.getBand(i);
    }

    // Apply logarithmic transformation and smoothing
    float smoothHi = lerp(0, log(1.0 + hiEnergy) * 100, 0.2);


    // 2. Generate a particle when the high-frequency sound exceeds the threshold
    if (smoothHi > threshold) {
        // the Louder the sound, the more of it is produced
        int count = (int)map(smoothHi, threshold, 100, 1, 10);
        for (int i = 0; i < count; i++) {
            // Released from elevated areas such as the center of the screen
            particles.add(new Particle(random(width), height / 2, map(smoothHi, threshold, 100, 180, 250)));
        }
    }

    // 3. particle updates and rendering
    for (int i = particles.size() - 1; i >= 0; i--) {
        Particle p = particles.get(i);
        p.update();
        // Pass the intensity of the high notes directly to Brightness
        p.display(map(smoothHi, 0, 100, 30, 100));

        if (p.isDead()) {
            particles.remove(i);
        }
    }

    saveFrame("frames/######.png");
}


void mousePressed() 
{
    if ( player.isPlaying() ) {
        player.pause();
    } else {
        player.play();
    }
}


void keyPressed()
{
    int skipMs = 10000;

    if (key == CODED) {
        if (keyCode == RIGHT) {
            player.skip(skipMs);
        } else if (keyCode == LEFT) {
            player.skip(-skipMs);
        }
    }
}


void stop()
{
    player.close();
    minim.stop();
    super.stop();
}
