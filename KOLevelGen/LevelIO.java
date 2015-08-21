
import java.io.*;

class LevelIO {

   public static void write(int[] board, PrintWriter wr) {
      wr.print("   {\n");
      wr.print("      {\n");
      for(int y = 0; y < LevelEditor.LEVEL_HEIGHT; y++) {
         wr.print("         {");
         for(int x = 0; x < LevelEditor.LEVEL_WIDTH; x++) {
            if(x > 0) {
               wr.print(", ");
            }
            final int index = y * LevelEditor.LEVEL_WIDTH + x;
            wr.print(Integer.toString(board[index]));
         }
         if(y < LevelEditor.LEVEL_HEIGHT - 1) {
            wr.print(" },\n");
         } else {
            wr.print(" }\n");
         }
      }
      wr.print("      }\n");
      wr.print("   },\n");
   }

   public static int[] read(InputStream is) {

      int[] board = new int[LevelEditor.LEVEL_WIDTH * LevelEditor.LEVEL_HEIGHT];

      int index = 0;
      StringBuffer buf = new StringBuffer();
      try {
         while(index < board.length) {

            // Skip characters we don't care about.
            int ch = 0;
            for(;;) {
               ch = is.read();
               if(ch >= '0' && ch <= '9') {
                  break;
               } else if(ch == -1) {
                  break;
               }
            }
            if(ch == -1) {
               break;
            }

            // Got the start of a block.
            // Read it.
            buf.append((char)ch);
            for(;;) {
               ch = is.read();
               if(ch < '0' || ch > '9') {
                  break;
               }
               buf.append((char)ch);
            }

            // Got a string.
            // Set the cell.
            board[index] = Integer.parseInt(buf.toString());
            buf.setLength(0);
            ++index;

         }
      } catch(Exception ex) {
         ex.printStackTrace();
      }

      return board;

   }

}

