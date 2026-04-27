class Particle
{
    PVector pos, vel, acc;
    float glitchOffset = 0;
    float lifespan;
    float friction = 0.92;
    float h; // color (Hue)



    Particle(float x, float y, float hue) 
    {
        pos = new PVector(x, y);
        // an initial velocity that propels it upward
        vel = PVector.random2D().mult(random(2, 3));
        acc = new PVector(0, 0);
        lifespan = 255;
        h = hue;
    }


    void glitch(float energy) 
    {
        if (energy > 50.0 && random(1) > 0.95) {
            glitchOffset = energy * random(-50, 50);
        } else {
            glitchOffset *= 0.5;
        }
    }


    void update(float energy)
    {
        if (energy > 0.0) {
            PVector direction = vel.copy().normalize();
            direction.mult(energy * 0.02);
            acc.add(direction);
        }
        vel.add(acc);
        vel.mult(friction);
        pos.add(vel);
        lifespan -= 5;
        acc.mult(0);
    }


    void display(float brightness)
    {
        pushMatrix();
        translate(glitchOffset, 0);
        // Increase the Brightness according to the intensity of the high-frequencies
        stroke(h, 80, brightness, lifespan);
        strokeWeight(5);
        point(pos.x, pos.y);
        popMatrix();
    }


    boolean isDead()
    {
        return lifespan < 0;
    }
}