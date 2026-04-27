class Particle
{
    PVector pos, vel, acc;
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


    void update(float energy)
    {
        if (energy > 0.0) {
            PVector direction = vel.copy().normalize();
            acc.add(direction.mult(energy * 0.5)); // energy * 0.015
        }
        vel.add(acc);
        vel.mult(friction);
        pos.add(vel);
        lifespan -= 5;
        acc.mult(0);
    }


    void display(float brightness, int ptclSize)
    {
        // Increase the Brightness according to the intensity of the high-frequencies
        stroke(h, 80, brightness, lifespan);
        strokeWeight(5 + ptclSize);
        point(pos.x, pos.y);
    }


    boolean isDead()
    {
        return lifespan < 0;
    }
}