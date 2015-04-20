//
//  WSVideoConvertUtil.m
//  TestEncrypt
//
//  Created by WOW on 15/3/29.
//  Copyright (c) 2015年 WoWSai. All rights reserved.
//

#import "WSVideoConvertUtil.h"

@implementation WSVideoConvertUtil
/*
public class VideoDecode extends Activity {
    
    String video_path = "http://mov1.shougongke.com/x/22.sgk";
    String origin = "da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.viedeo_decode);
        Thread t = new Thread(new Load());
        t.start();
        
        
        String s = "1245678";
        byte[] da = s.getBytes();
        for(byte a:da)
        {
            LogUtil.e("", "----" + a);
        }
        
        LogUtil.e("", "55^75 " + (55^75));
        
        
    }
    
    class Load implements Runnable {
        @Override
        public void run() {
            URL path;
            InputStream is = null;
            FileOutputStream fos = null;
            try {
                path = new URL(video_path);
                HttpURLConnection connection = (HttpURLConnection) path.openConnection();
                if (connection != null && connection.getResponseCode() == 200) {
                    is = connection.getInputStream();
                    byte[] auth = new byte[16];
                    is.read(auth);
                    if (checkSGK(auth)) {
                        if (checkVersion(auth)) {
                            byte[] key1 = getCharKey(getKey(auth));
                            byte[] head = new byte[1024];
                            is.read(head);
                            for (int i = 0; i < head.length; i++) {
                                head[i] = (byte) (key1[i] ^ head[i]);
                            }
                            File f = new File(StorageUtils.getExternalCacheDir(VideoDecode.this).getAbsoluteFile(), "test.mp4");
                            
                            if (!f.exists()) {
                                f.createNewFile();
                            }
                            Log.e("", f.getAbsolutePath());
                            fos = new FileOutputStream(f);
                            fos.write(head);
                            
                            byte[] buffer = new byte[2048];
                            
                            int len = -1;
                            while ((len = is.read(buffer)) != -1) {
                                fos.write(buffer, 0, len);
                            }
                            
                            Intent intent = new Intent(Intent.ACTION_VIEW);
                            intent.setDataAndType(Uri.fromFile(f), "video/mp4");
                            startActivity(intent);
                        } else {
                            // update
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
                
                if (fos != null) {
                    try {
                        fos.close();
                    } catch (IOException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }
            }
            
        }
        
        boolean checkSGK(byte[] data) {
            final char s = 's';
            final char g = 'g';
            final char k = 'k';
            if (data == null) {
                return false;
            }
            return s == data[0] || g == data[1] || k == data[2];
        }
        
        boolean checkVersion(byte[] data) {
            if (data == null) {
                return false;
            }
            
            return data[3] == 0x31;
        }
        
        int getKey(byte[] data) {
            return data[5];
        }
        
        byte[] getCharKey(int position) {
            String keysub = origin.substring(position);
            while (keysub.length() < 1024) {
                keysub = keysub + keysub;
            }
            
            byte[] zu = keysub.getBytes();
            for (int i = 0; i < 1024; i++) {
                zu[i] = (byte) (zu[i] ^ position);
            }
            return zu;
        }
        
    }
    
}
 
 kyesub == 75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d
 
 
 kyesub == 75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d75161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d
 
 
 
 byte array zu = |~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}x//.z~-)}ss.}/|~z}z||rs))/{y/xsz{r~~sz|x~rsx?*8 <%*||}{~.**sr-rx*}.rr~.{y{)z{/}).zyrxrxs*)zz}}-(|r.(d13ed837a829f0073610189643dde15fb4688e6d

 
 
 hean array==== ������ ftypisom������isomiso2avc1mp41������free����mdatH@�`�����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������E���H��,� �#��x264 - core 135 r2345 f0c1c53 - H.264/MPEG-4 AVC codec - Copyleft 2003-2013 - http://www.videolan.org/x264.html - options: cabac=1 ref=3 deblock=1:0:0 analyse=0x3:0x113 me=hex subme=7 psy=1 psy_rd=1.00:0.00 mixed_ref=1 me_range=16 chroma_me=1 trellis=1 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-2 threads=6 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=3 b_pyramid=2 b_adapt=1 b_bias=0 direct=1 weightb=1 open_gop=0 weightp=2 keyint=250 keyint_min=13 scenecut=40 intra_refresh=0 rc_lookahead=40 rc=crf mbtree=1 crf=23.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 ip_ratio=1.40 aq=1:1.00�������"e������ߋi4�C�͍c�_+r�Ra��Oc����H���Y�m��>��ʼS�0[t�M���B�U�ɒ0d�����Z�0�ڟ����vs���τ7l߂L�
 04-02 14:13:58.327: E/(12182): /storage/sdcard0/Android/data/com.wowsai.crafter4Android/cache/test.mp4
 
*/

@end
