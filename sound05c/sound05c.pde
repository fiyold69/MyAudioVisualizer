import java.lang.Math.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer player;
FFT fft;

ArrayList<Particle> ptcls = new ArrayList<Particle>();
String audioName;
int threshold = 70;



void setup()
{
    size(1024, 576, P2D);
    colorMode(HSB, 360, 100, 100, 255);

    minim = new Minim(this);

    selectInput("Choose a song file: ", "fileSelected");
}


// The Function called by "selectInput"
void fileSelected(File selection)
{
    if (selection == null) {
        println("No file was selected. The program will now exit.");
        exit();
    } else {
        player = minim.loadFile( selection.getAbsolutePath(), 1024);
        fft = new FFT(player.bufferSize(), player.sampleRate());
        player.play();
        audioName = selection.getName();
        println("Start playback: " + audioName);
    }
}



void draw()
{
    background(0);
    noStroke();

    if (player == null || !player.isPlaying() ) {
        fill(255, map(millis() % 2000, 0, 2000, 255, 0)); // 点滅効果
        textAlign(CENTER);
        text("NOW PLAYING: " + audioName, width/2, 40);
        return;
    }

    fft.forward( player.mix );


    // 1. Extract high-frequency energy and Apply logarithmic transformation
    float hiEnergy = 20 * log(1.0 + fft.calcAvg(3000, 20000) * 400);
    float kickEnergy = fft.calcAvg(60, 150);
    float subBassEnergy = fft.calcAvg(20, 80);
    // The Ratio is 400 times


    // 2. Generate a particle when the high-frequency sound exceeds the threshold
    if (hiEnergy > threshold) {
        // the Louder the sound, the more of it is produced
        int count = (int)map(hiEnergy, threshold, 100, 1, 10);
        for (int i = 0; i < count; i++) {
            // Released from elevated areas such as the center of the screen
            ptcls.add(new Particle(random(width), height / 2, map(hiEnergy, threshold, 100, 180, 250)));
        }
    }


    // 3. particle updates and rendering
    for (int i = ptcls.size() - 1; i >= 0; i--) {
        Particle p = ptcls.get(i);
        p.update(fft.calcAvg(3000, 20000));
        // Pass the intensity of the high notes directly to Brightness
        p.display(map(hiEnergy, 0, 100, 20, 100), (int)kickEnergy / 15);

        if (p.isDead()) {
            ptcls.remove(i);
        }
    }

    if (subBassEnergy > 50.0) glitchFilter(subBassEnergy);

    // saveFrame("frames/######.png");
}


void glitchFilter(float energy)
{
    // 1. load pixel data
    loadPixels();

    int numStrips = (int)random(10, 30);
    float maxOffset = energy * 100;

    // 2. 
    for (int i = 0; i < numStrips; i++) {
        int h = (int)random(5, 50);
        int y = (int)random(0, height - h);

        int offsetX = (int)random(-maxOffset, maxOffset);

        if (random(1) > 0.1) {
            copy(0, y, width, h, offsetX, y, width, h);
        }
    }

    if (energy > 60.0 && random(1) > 0.95) {
        //filter(INVERT);
        //filter(POSTERIZE, 2);
        filter(DILATE);
    }
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
