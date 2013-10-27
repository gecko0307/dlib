module dlib.image.fthread;

import core.thread;
import dlib.image.image;

abstract class FilteringThread: Thread
{
    protected SuperImage image;
    protected SuperImage output;

    this(SuperImage img)
    {
        super(&run);
        image = img;
    }
    
    SuperImage filtered()
    {
        start();
        while(isRunning)
            onRunning();
        onFinished();
        return output;
    }
    
    // override these:
    void run();
    void onRunning();
    void onFinished();
}