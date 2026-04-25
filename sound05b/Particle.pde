class Particle
{
    PVector pos, vel;
    float lifespan;
    float h; // color (Hue)



    Particle(float x, float y, float hue) 
    {
        pos = new PVector(x, y);
        // an initial velocity that propels it upward
        vel = PVector.random2D();
        vel.mult(random(1, 5));
        lifespan = 255;
        h = hue;
    }


    void update()
    {
        pos.add(vel);
        lifespan -= 5;
    }


    void display(float brightness)
    {
        // Increase the Brightness according to the intensity of the high-frequencies
        stroke(h, 80, brightness, lifespan);
        strokeWeight(5);
        point(pos.x, pos.y);
    }


    boolean isDead()
    {
        return lifespan < 0;
    }
}