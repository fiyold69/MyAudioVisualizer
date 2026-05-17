import java.lang.Math.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer player;
FFT fft;

ArrayList<Particle> ptcls = new ArrayList<Particle>();
String audioName;
int threshold = 40;



void setup()
{
    size(1280, 720, P2D);
    frameRate(30);
    //size(1920, 1080, P2D);
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
        player.loop();
        audioName = selection.getName();
        println("Start playback: " + audioName);
    }
}



void draw()
{
    background(0);
    noStroke();

    if (player == null || !player.isPlaying() ) {
        fill(255, map(millis() % 2000, 0, 2000, 255, 0));
        textAlign(CENTER);
        text("NOW PLAYING: " + audioName, width/2, 40);
        return;
    }

    fft.forward( player.mix );


    // 1. Extract energy and Apply logarithmic transformation
    int factor = 80;
    float hiEnergy = fft.calcAvg(3000, 20000) * factor;
    //println(hiEnergy);
    float kickEnergy = fft.calcAvg(60, 150);
    float subBassEnergy = fft.calcAvg(20, 60);


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
        p.update(hiEnergy / 40);
        // Pass the intensity of the high notes directly to Brightness
        p.display(map(hiEnergy, 0, 100, 20, 100), (int)kickEnergy / 10);

        if (p.isDead()) {
            ptcls.remove(i);
        }
    }

    if (subBassEnergy > 50.0) glitchFilter(subBassEnergy);

    saveFrame("frames/######.png");
}


void glitchFilter(float energy)
{
    // 1. load pixel data
    loadPixels();

    int numStrips = (int)random(10, 30);
    float maxOffset = energy * 300;

    // 2. 
    for (int i = 0; i < numStrips; i++) {
        int h = (int)random(5, 50);
        int y = (int)random(0, height - h);

        int offsetX = (int)random(-maxOffset, maxOffset);

        if (random(1) > 0.1) {
            copy(0, y, width, h, offsetX, y, width, h);
        }
    }

    if (energy > 80.0 && random(1) > 0.95) {
        //filter(INVERT);
        filter(POSTERIZE, 2);
        //filter(DILATE);
    }
}


void mousePressed() 
{
    if ( player.isPlaying() ) {
        player.pause();
    } else {
        player.loop();
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
