
import java.io.*;
import java.util.*;

class KOLevelGen {

   public static void main(String[] args) {

      if(args.length == 1) {
         try {
            File f = new File(args[0]);
            if(f.isDirectory()) {
               TreeMap<Integer, LinkedList<String>> levels;
               levels = new TreeMap<Integer, LinkedList<String>>();
               File[] fl = f.listFiles();
               for(int x = 0; x < fl.length; x++) {
                  File t = fl[x];
                  if(t.isFile()) {
                     FileInputStream is = new FileInputStream(t);
                     int[] board = LevelIO.read(is);
                     final int s = LevelStats.computeScore(board);
                     System.out.println(t.toString() + " -> "
                                        + Integer.toString(s));
                     LinkedList<String> strs = levels.get(s);
                     if(strs != null) {
                        strs.add(t.toString());
                     } else {
                        strs = new LinkedList<String>();
                        strs.add(t.toString());
                        levels.put(s, strs);
                     }
                  }
               }
               System.out.println("Sorted levels:");
               while(!levels.isEmpty()) {
                  Integer score = levels.firstKey();
                  Iterator<String> it = levels.remove(score).iterator();
                  while(it.hasNext()) {
                     String fn = it.next();
                     System.out.println(fn + " -> " + score.toString());
                  }
               }
            }
         } catch(Exception ex) {
            ex.printStackTrace();
         }
         return;
      }

      LevelEditor editor = new LevelEditor();
      editor.show();

   }

}

