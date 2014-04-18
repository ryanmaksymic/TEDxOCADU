/*

 TEDxOCADU
 
 Ryan Maksymic
 
 Created on January 8, 2013
 
 */


color red;

PFont font;
PFont fontBold;

PImage logo;

TwC twitter;
ArrayList searchResult;
String[] tweetLine = new String[9];
String tweetOnscreen;
float tweet_xpos;
float tweet_ypos;
float tweet_speed;
float tweet_width;
int tweet_count;

float shard_width;
float shard_height;
Shard[] shards;
PVector[] shard_pos = {
  new PVector(432.5, 220), // 1
  new PVector(490, 320), 
  new PVector(547.5, 220), 
  new PVector(605, 320), 
  new PVector(777.5, 220), // 5
  new PVector(720, 320), 
  new PVector(892.5, 220), 
  new PVector(835, 320), 
  new PVector(490, 320), 
  new PVector(547.5, 420), // 10
  new PVector(605, 320), 
  new PVector(662.5, 420), 
  new PVector(720, 320), 
  new PVector(777.5, 420), 
  new PVector(835, 320), // 15
  new PVector(490, 520), 
  new PVector(547.5, 420), 
  new PVector(605, 520), 
  new PVector(662.5, 420), 
  new PVector(720, 520), // 20
  new PVector(777.5, 420), 
  new PVector(835, 520), 
  new PVector(490, 520), 
  new PVector(432.5, 620), 
  new PVector(605, 520), // 25
  new PVector(547.5, 620), 
  new PVector(720, 520), 
  new PVector(777.5, 620), 
  new PVector(835, 520), 
  new PVector(892.5, 620), // 30
};
float[] shard_speed = {
  1, 2, 4
};
int shard_count;
int index;    // counts shard instances
int flip_index;    // 0 = shard points up; 1 = shard points down
boolean shards_near;
boolean shards_home;
int shards_near_test;
int shards_home_test;
float timeCheck;


void setup()
{
  size(1440, 900);
  smooth();    // anti-aliased drawings
  noCursor();

  red = color(255, 0, 0, 236);

  stroke(red);

  font = createFont("Helvetica", 90, true);    // use Helvetica font w/anti-aliasing
  fontBold = createFont("Helvetica-Bold", 90, true);    // use Helvetica Bold font w/anti-aliasing

  logo = loadImage("TEDxOCADU_black.png");

  shard_width = 115;
  shard_height = 100;
  shard_count = shard_pos.length;
  shards = new Shard[shard_count];
  index = 0;
  flip_index = 1;
  shards_near = false;
  shards_home = false;
  for (int i = 0; i < shard_count; i++)
  {
    shards[index++] = new Shard(shard_pos[i].x, shard_pos[i].y, shard_speed[int(random(3))], int(random(2)), flip_index);    // create a shard instance

    flip_index = 1 - flip_index;    // toggle flip index
  }
  timeCheck = 0;

  tweet_xpos = width;
  tweet_ypos = 730;
  tweet_speed = 3.3;
  twitter = new TwC("xoDuMIyALHl7eDHYmMtmg", //OAuthConsumerKey 
  "MCxj44ri43e5yUi1tRk9M8RMYWBtRHyInACUtsQE", //OAuthConsumerKeySecret
  "28286515-LRSSY57dw4J2qPow1PvBNZhZbx1TUkKtccwoVMNhb", //AccessToken
  "uRoW86uOudd6a4JuFpqmd6LYIPFGW6LePp46koP2s");    //AccessTokenSecret
  twitter.connect();
  grabTweets();
  tweetOnscreen = tweetLine[tweet_count];
}


void draw()
{
  background(0);

  // TEDxOCADU logo
  imageMode(CENTER);
  image(logo, width/2, 100, 500, 127);

  // shard movement:

  shards_near_test = 0;
  for (int q = 0; q < shard_count; q++)
  {
    shards_near_test = shards_near_test + shards[q].checkNear(150);
  }

  if (shards_near_test == shard_count)
  {
    shards_near = true;
  }
  else
  {
    shards_near = false;

    timeCheck = 1e30;    // reset timeCheck
  }

  shards_home_test = 0;
  for (int p = 0; p < shard_count; p++)
  {
    shards_home_test = shards_home_test + shards[p].checkHome();
  }

  if (shards_home_test == shard_count)
  {
    if (shards_home == false)
    {
      timeCheck = millis();

      shards_home = true;
    }
  }
  else
  {
    shards_home = false;
  }

  for (int k = 0; k < shard_count; k++)
  {
    if ((shards_near) && (shards[k].checkNear(2) == 1) && (millis() < (timeCheck + 2500)))
    {
      shards[k].still();    // pause on "X"

      shards[k].randomPath();
    }
    else
    {
      shards[k].move();
    }

    shards[k].display();
  }

  // scrolling tweets:

  textAlign(LEFT, CENTER);
  textFont(font, 40);
  fill(255);

  tweet_xpos = tweet_xpos - tweet_speed;

  tweet_width = textWidth(tweetOnscreen);

  if (tweet_xpos < -tweet_width)
  {
    tweet_count++;

    if (tweet_count > 8)
    {
      grabTweets();
    }

    tweetOnscreen = tweetLine[tweet_count];

    tweet_xpos = width;
  }

  text(tweetOnscreen, tweet_xpos, tweet_ypos);
}


void grabTweets()
{
  tweet_count = 0;    // reset index

  searchResult = twitter.search("#TEDxOCADU");    // get fresh tweets
  for (int j = 0; j < searchResult.size(); j++)
  {  
    Tweet t = (Tweet)searchResult.get(j);  
    String user = t.getFromUser();
    String msg = t.getText();
    tweetLine[j] = "@" + user + ": " + msg;
  }
}

void keyPressed()
{
  if (key == 'r')
  {
    setup();
  }
}


class Shard
{
  // data:
  color c;    // shard colour
  float xpos;
  float xpos_init;    // initial x position
  float ypos;
  float dy;    // shard height
  float xspeed;
  float d;    // 1 = moves right; 0 = moves left

  // constructor:
  Shard(float xpos_, float ypos_, float xspeed_, float d_, int flipped_)
  {
    c = red;
    dy = shard_height;
    xpos = xpos_;
    xpos_init = xpos;
    ypos = ypos_;
    xspeed = xspeed_;
    d = d_;

    if (flipped_ == 1)
    {
      dy = -dy;
    }

    if (d == 1)
    {
      xspeed = xspeed;
    }
    else if (d == 0)
    {
      xspeed = -xspeed;
    }
  }

  // methods:

  void display()
  {
    fill(c);
    triangle(xpos, ypos, xpos + shard_width/2, ypos - dy, xpos + shard_width, ypos);
  }

  void still()
  {
    xpos = xpos_init;
  }

  void move()
  {
    if ((shards_near) && (((xspeed > 0) && (xpos < xpos_init)) || ((xspeed < 0) && (xpos > xpos_init))))
    {
      if (xpos < (xpos_init + 32) && xpos > (xpos_init - 32))
      {
        xpos = xpos + xspeed/16;
      }
      else if (xpos < (xpos_init + 64) && xpos > (xpos_init - 64))
      {
        xpos = xpos + xspeed/8;
      }
      if (xpos < (xpos_init + 150) && xpos > (xpos_init - 150))
      {
        xpos = xpos + xspeed/2;
      }
    }
    else
    {
      xpos = xpos + xspeed;
    }

    if (d == 1 && xpos > width)
    {
      xpos = 0 - shard_width;
    }
    else if (d == 0 && (xpos + shard_width) < 0)
    {
      xpos = width;
    }
  }

  int checkNear(int val)
  {
    int shard_near = 0;

    if (xpos < (xpos_init + val) && xpos > (xpos_init - val))
    {
      shard_near = 1;
    }
    else
    {
      shard_near = 0;
    }

    return shard_near;
  }

  int checkHome()
  {
    int shard_home = 0;

    if (xpos == xpos_init)
    {
      shard_home = 1;
    }
    else
    {
      shard_home = 0;
    }

    return shard_home;
  }

  void randomPath()
  {
    xspeed = shard_speed[int(random(3))];

    d = int(random(2));

    if (d == 1)
    {
      xspeed = xspeed;
    }
    else if (d == 0)
    {
      xspeed = -xspeed;
    }
  }
}

