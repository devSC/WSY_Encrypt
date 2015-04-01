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
*/

@end
