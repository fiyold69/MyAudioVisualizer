import ddf.minim.*;

Minim minim;
AudioPlayer player;
int waveH = 100;

void setup() {

    size(512, 200, P2D);

    minim = new Minim(this); //初期化

    /* バッファ（メモリ上のスペース。この場合は512byteのfloat型の配列）を確保し、
    サウンドファイルを読み込む。指定がなければ通常1024 */
    player = minim.loadFile("../Heartless Solution -To The Worthless Destination-.mp3", 512);
    
    player.play();
}


void draw() {

    background(0);
    stroke(255);

    //波形を描く
    //left.get()とright.get()が返す値は-1から+1なので、見やすくするために、
    //waveH（初期値は100）を掛けている。
    //サウンドファイルがモノラルの場合は、left.get()とright.get()が返す値は同じ。

    for (int i = 0; i < player.left.size() - 1; i++) { //size()は音源の時間
        point(i, 50 + player.left.get(i) * waveH);
        point(i, 150 + player.right.get(i) * waveH);
    }
}


void stop() {
    player.close();
    minim.stop();
    super.stop();
}