//
//  AudioConverter.m
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

#import "AudioConverter.h"
#import "lame/lame.h"

@implementation AudioConverter

- (NSString *)mp3FileFromM4aFile:(NSString *)m4aFilePath {
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:mp3FileName];
    @try {
        int read, write;

        FILE *pcm = fopen([m4aFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 16000);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        lame_set_num_channels(lame, 1);

        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);

        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        return mp3FilePath;
    }
}

@end
