import java.lang.Math.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Minim minim;
AudioPlayer player;
FFT fft;

ArrayList<Particle> ptcls = new ArrayList<Particle>();
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
        println("Start playback: " + selection.getName());
    }
}



void draw()
{
    background(0);
    noStroke();

    if (player == null || !player.isPlaying() ) return;

    fft.forward( player.mix );


    // 1. Extract high-frequency energy and Apply logarithmic transformation
    float hiEnergy = 20 * log(1.0 + fft.calcAvg(3000, 20000) * 400);
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
        p.update();
        // Pass the intensity of the high notes directly to Brightness
        p.display(map(hiEnergy, 0, 100, 30, 100));

        if (p.isDead()) {
            ptcls.remove(i);
        }
    }

    // saveFrame("frames/######.png");
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
