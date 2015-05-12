#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

typedef struct
{
  float time;
  float freq;
} timefreq_t;

#define MAX_TIME_FREQ 65536
timefreq_t timefreq[MAX_TIME_FREQ];
int max_timefreq;

static void read_pitch_file(FILE *f)
{
  float t, freq;
  int count;
  int i = 0;
  while ((count = fscanf(f, "%f,%f\n", &t, &freq)) >= 1)
  {
    assert(count == 2);
    timefreq[i].time = t;
    timefreq[i].freq = freq;
    i++;
    assert(i < MAX_TIME_FREQ);
  }
  max_timefreq = i;
}

static float pitch_at_time(float time)
{
  int i0 = 0;
  int i1 = max_timefreq;
  float x;
  if (timefreq[i0].time > time || timefreq[i1].time > time) return 0.0f;

  while (i1 - i0 > 1)
  {
    int i2 = (i0 + i1) / 2;
    if (timefreq[i2].time > time)
      i1 = i2;
    else
      i0 = i2;
  }

  if (timefreq[i0].freq == 0.0f || timefreq[i1].freq == 0.0f) return 0.0f;

  x = (time - timefreq[i0].time) / (timefreq[i1].time - timefreq[i0].time);
  return timefreq[i0].freq + x * (timefreq[i1].freq - timefreq[i0].freq);
}

static float degree_to_freq(int degree)
{
  int scale[8] = {-1, 0, 3, 4, 6, 7, 8, 10};
  degree = (degree >> 3) * 12 + scale[degree & 7];
  return pow(2.0, degree / 12.0) * 440.0;
}

static char in_buffer[4096];
static char out_buffer[4096];

static int process_wav(FILE *in, FILE *out, int bytes_per_frame, int frames_per_second, int start_degree, int direction)
{
  size_t count = 0;
  int inpos = 0;
  float input_time = 0.0f;
  float input_pitch;
  float output_time = 0.0f;
  int output_frames = 0;
  int out_count;
  float target_pitch;
  int degree = start_degree;
  int counter = 0;
  float start_time = -1000.0f;
  int outpos = 0;
  int data_size = 0;
  int i;
  float prev_input_pitch = 0.0f;

  while(1)
  {
    if (inpos == count)
    {
      count = fread(in_buffer, 1, 4096, in);
      if (count == 0) break;
      inpos = 0;
    }

    input_time += 1.0 / frames_per_second;
    input_pitch = pitch_at_time(input_time);

    if (input_pitch != 0.0f)
    {
      if (prev_input_pitch == 0.0f && input_time - start_time > 2.0)
      {
        start_time = input_time;
        target_pitch = degree_to_freq(degree);
        degree += direction;
      }
    }

    if (counter % (frames_per_second / 4) == 0)
    {
      printf("%3d -> %3d    at %f\n", (int)input_pitch, (int)target_pitch, input_time);
    }

    if (input_pitch != 0.0f)
    {
      output_time += input_pitch / target_pitch / frames_per_second;
      out_count = (int)(output_time * frames_per_second - output_frames + 0.5f);
      output_frames += out_count;
      for (i = 0; i < out_count; i++)
      {
        memcpy(out_buffer + outpos, in_buffer + inpos, bytes_per_frame);
        outpos += bytes_per_frame;
        data_size += bytes_per_frame;
        if (outpos == 4096)
        {
          fwrite(out_buffer, 1, outpos, out);
          outpos = 0;
        }
      }
    }

    inpos += bytes_per_frame;
    counter++;
    prev_input_pitch = input_pitch;
  }
  fwrite(out_buffer, 1, outpos, out);
  return data_size;
}

static void read_these_chars(FILE *f, const char *str)
{
  while (*str != '\0')
  {
    char ch;
    size_t r = fread(&ch, 1, 1, f);
    assert(r == 1);
    if (ch != *str) printf("Expecting %s\n", str);
    assert(ch == *str);
    str++;
  }
}

static uint32_t read_uint32(FILE *f)
{
  uint32_t n;
  size_t r = fread(&n, 1, 4, f);
  assert(r == 4);
  return n;
}

static uint16_t read_uint16(FILE *f)
{
  uint16_t n;
  size_t r = fread(&n, 1, 2, f);
  assert(r == 2);
  return n;
}

#define CHARS_AS_INT(a,b,c,d) ((a)|(b)<<8|(c)<<16|(d)<<24)
static void read_wav_header(FILE *f, int *bytes_per_frame, int *frames_per_second)
{
  read_these_chars(f, "RIFF");
  uint32_t file_size = read_uint32(f);
  read_these_chars(f, "WAVE");
  int have_fmt = 0;
  uint32_t section_size, n, data_size;

  while(1)
  {
    uint32_t section = read_uint32(f);
    if (section == CHARS_AS_INT('f','m','t',' '))
    {
      assert(!have_fmt);
      section_size = read_uint32(f);
      assert(section_size >= 16);
      n = read_uint16(f);
      assert(n == 1);   // type=PMC
      n = read_uint16(f);
      assert(n == 2);   // stereo
      n = read_uint32(f);
      assert(n == 44100); // sample rate
      *frames_per_second = n;
      n = read_uint32(f);
      assert(n == 44100 * 4);  // byte rate
      n = read_uint16(f);
      assert(n == 4);   // 16 bit stereo
      *bytes_per_frame = n;
      n = read_uint16(f);
      assert(n == 16);  // 16 bit
      have_fmt = 1;

      printf("Skipping %d bytes of fmt section\n", section_size - 16);
      fseek(f, section_size - 16, SEEK_CUR);
    }
    else if (section == CHARS_AS_INT('d','a','t','a'))
    {
      assert(have_fmt);
      data_size = read_uint32(f);
      assert(file_size = data_size + 36);
      assert(data_size % 2 == 0);
      break;
    }
    else
    {
      printf("Skipping section %c%c%c%c\n", section & 255, section >> 8 & 255, section >> 16 & 255, section >> 24);
      section_size = read_uint32(f);
      fseek(f, section_size, SEEK_CUR);
    }
  }
}

static void write_wav_placeholder(FILE *f)
{
  char blank[44];
  memset(blank, 0, 44);
  fwrite(blank, 1, 44, f);
}

#define INT_AS_CHARS(n) (n)&255,((n)>>8)&255,((n)>>16)&255,((n)>>24)&255
static void write_wav_header(FILE *f, size_t data_size)
{
  char header[44] = {
    'R','I','F','F',
    INT_AS_CHARS(36 + data_size),
    'W','A','V','E',
    'f','m','t',' ',
    16,0,0,0,
    1,0,
    2,0,
    INT_AS_CHARS(44100),  // sample rate
    INT_AS_CHARS(44100*4),
    4,0,
    16,0,
    'd','a','t','a',
    INT_AS_CHARS(data_size)};
  fwrite(header, 1, 44, f);
}

int main(int argc, char **argv)
{
  char filename[1024];
  FILE *in, *out;
  int bytes_per_frame, frames_per_second, data_size;
  int start_degree = -16;
  int direction = 1;

  if (argc >= 3)
  {
    sscanf(argv[2], "%d", &start_degree);
  }
  if (argc >= 4)
  {
    sscanf(argv[3], "%d", &direction);
  }

  printf("start degree = %d, direction = %d\n", start_degree, direction);

  sprintf(filename, "alex pitch analysis/%s.csv", argv[1]);
  in = fopen(filename, "r");
  read_pitch_file(in);
  fclose(in);

  sprintf(filename, "alex raw/%s.wav", argv[1]);
  in = fopen(filename, "rb");

  sprintf(filename, "c/%s tuned.wav", argv[1]);
  out = fopen(filename, "wb");

  read_wav_header(in, &bytes_per_frame, &frames_per_second);
  write_wav_placeholder(out);
  data_size = process_wav(in, out, bytes_per_frame, frames_per_second, start_degree, direction);
  fseek(out, 0, SEEK_SET);
  write_wav_header(out, data_size);

  fclose(in);
  fclose(out);
  return 0;
}
