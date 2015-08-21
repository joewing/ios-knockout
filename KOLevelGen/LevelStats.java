
import java.util.*;

class LevelStats {

   private static final class ScoreNode {

      public ScoreNode(int s, int[] v) {
         score = s;
         values = v;
         values1 = new int[9];
         rotate(values, values1);
         values2 = new int[9];
         rotate(values1, values2);
         values3 = new int[9];
         rotate(values2, values3);
      }

      private void rotate(int[] in, int[] out) {
         out[0] = in[2];
         out[1] = in[5];
         out[2] = in[8];
         out[3] = in[1];
         out[4] = in[4];
         out[5] = in[7];
         out[6] = in[0];
         out[7] = in[3];
         out[8] = in[6];
      }

      public boolean check(int bx, int by, boolean is_first) {
         if(       check(values, bx, by, is_first)) {
            return true;
         } else if(check(values1, bx, by, is_first)) {
            return true;
         } else if(check(values2, bx, by, is_first)) {
            return true;
         } else if(check(values3, bx, by, is_first)) {
            return true;
         } else {
            return false;
         }
      }

      private boolean check(int[] v, int bx, int by, boolean is_first) {

         int index = 0;
         for(int y = 0; y < 3; y++) {
            final int ny = y - 1 + by;
            if(ny < 0 || ny >= height) {
               for(int x = 0; x < 3; x++) {
                  if(v[index] != 3 && v[index] != 1) {
                     return false;
                  }
                  ++index;
               }
               continue;
            }
            for(int x = 0; x < 3; x++) {
               final int nx = x - 1 + bx;
               if(nx < 0 || nx >= width) {
                  if(v[index] != 3 && v[index] != 1) {
                     return false;
                  }
                  ++index;
                  continue;
               } else if(x == 1 && y == 1) {
                  ++index;
                  continue;
               }
               if(!matches(v[index], board[ny * width + nx], is_first)) {
                  return false;
               }
               ++index;
            }
         }

         return true;

      }

      private boolean matches(int check, int type, boolean is_first) {
         int mask = 0;
         switch (type)
         {
         case 0:  // Empty
            mask = 1;
            break;
         case 1:  // First
            mask = 4;
            break;
         case 2:  // Kill
            mask = 8;
            break;
         case 3:  // Last
            mask = 4;
            break;
         case 4:  // Wall
            mask = 2;
            break;
         case 5:
         case 7:
         case 9:
         case 11:
         case 13:
         case 15: // Block
            mask = 4;
            break;
         case 6:
         case 8:
         case 10:
         case 12:
         case 14:
         case 16: // Switcher (killer at the beginning).
            mask = is_first ? 8 : 2;
            break;
         default:
            break;
         }
         return (check & mask) != 0;
      }

      public int getScore() {
         return score;
      }

      private int score;
      private int first_score;
      private int[] values;
      private int[] values1;
      private int[] values2;
      private int[] values3;

   }

   private static final int FIRST_BLOCK   = 1;
   private static final int KILL_BLOCK    = 2;
   private static final int LAST_BLOCK    = 3;
   private static final int WALL_BLOCK    = 4;

   private static final int[] dirx = { -1,  1,  0,  0 };
   private static final int[] diry = {  0,  0, -1,  1 };

   // 1  -> empty
   // 2  -> wall
   // 4  -> block       // 6  -> non-empty
   // 8  -> switcher    // 15 -> empty/wall/block/switcher
   // 16 -> killer      // 31 -> anything
   private static ScoreNode[] scores = {

      new ScoreNode(100, new int[] { 16,  1, 16,
                                     16,  4, 16,
                                     31, 16, 31 }),

      new ScoreNode(75,  new int[] { 16,  1, 31,
                                     16,  4, 16,
                                     31, 16, 31 }),

      new ScoreNode(75,  new int[] { 31,  1, 16,
                                     16,  4, 16,
                                     31, 16, 31 }),

      new ScoreNode(50,  new int[] { 31,  1, 31,
                                     16,  4, 16,
                                     31, 16, 31 }),

      new ScoreNode(25,  new int[] { 31,  1, 31,
                                     16,  4, 16,
                                     31, 31, 31 }),

      new ScoreNode(10,  new int[] { 31,  1, 31,
                                     16,  4, 31,
                                     31, 31, 16 }),

      new ScoreNode(10,  new int[] { 31,  1, 31,
                                     31,  4, 16,
                                     16, 31, 31 })

   };

   private static int width = 0;
   private static int height = 0;
   private static int[] board = null;
   private static HashSet<Integer> blocks = null;
   private static int clearable = 0;
   private static int last_count = 0;
   private static int first_count = 0;

   public static int computeScore(int[] b) {

      width = LevelEditor.LEVEL_WIDTH;
      height = LevelEditor.LEVEL_HEIGHT;
      board = b;
      clearable = 0;
      last_count = 0;
      first_count = 0;

      // Find the starting point.
      int ballx = 0;
      int bally = 0;
      for(int y = 0; y < height; y++) {
         for(int x = 0; x < width; x++) {
            switch(board[y * width + x]) {
            case 255:      // Ball
               board[y * width + x] = -1;
               ballx = x;
               bally = y;
               break;
            case LAST_BLOCK:
               ++last_count;
               // Fall trhough.
            case FIRST_BLOCK:
               ++first_count;
               // Fall through.
            case 5:
            case 7:
            case 9:
            case 11:
            case 13:
            case 15:
               ++clearable;
               break;
            default:
               break;
            }
         }
      }
      first_count -= last_count;

      // Make sure the level is beatable with one ball.
      int score = 0;
      blocks = new HashSet<Integer>();
      int iter = 0;
      boolean updated = true;
      boolean is_first = true;
      for(; clearable > 0 && updated; iter++) {

         updated = false;

         // Determine the best block to clear.
         int best_score = Integer.MAX_VALUE;
         int best_x = 0;
         int best_y = 0;
         for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {

               // Check if this is a block we should visit.
               final int t = board[y * width + x];
               if(t < 0 || t == KILL_BLOCK || t == WALL_BLOCK) {
                  continue;
               }

               // Check if we can clear this block.
               if(!canClear(x, y)) {
                  continue;
               }

               // See if we can update this block.
               if(!isUpdatable(x, y, is_first)) {
                  continue;
               }

               // Compute the score of this block.
               final int s = getScore(x, y, is_first);
               if(s < best_score) {
                  updated = true;
                  best_score = s;
                  best_x = x;
                  best_y = y;
               }
            }
         }

         // Clear the block.
         if(updated) {
            is_first = doUpdate(best_x, best_y, is_first);
            score += best_score;
         }

      }

/*
      if(clearable > 0) {

         System.out.println("");
         System.out.println("Impossible level");
         System.out.println("Blocks left: " + Integer.toString(clearable));

         Iterator<Integer> it = blocks.iterator();
         while(it.hasNext()) {
            Integer value = it.next();
            System.out.println("BLOCK: " + value.toString());
         }

         for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {
               System.out.print(Integer.toString(board[y * width + x]) + " ");
            }
            System.out.println("");
         }

      }
*/

      if(clearable > 0) {
         return Integer.MAX_VALUE;
      } else {
         return score;
      }

   }

   private static boolean canClear(int x, int y) {
      for(int d = 0; d < 4; d++) {
         final int nx = dirx[d] + x;
         final int ny = diry[d] + y;
         if(nx < 0 || nx >= width) {
            continue;
         }
         if(ny < 0 || ny >= height) {
            continue;
         }
         if(board[ny * width + nx] < 0) {
            return true;
         }
      }
      return false;
   }

   private static boolean doUpdate(int x, int y, boolean is_first) {
      final int t = board[y * width + x];
      if(t == 0) {
         board[y * width + x] = -1;
      } else if(t == FIRST_BLOCK && is_first) {
         board[y * width + x] = -1;
         --first_count;
         --clearable;
         is_first = first_count != 0;
      } else if(blocks.contains(t)) {
         board[y * width + x] = -1;
         --clearable;
         if(clearable == last_count) {
            blocks.add(LAST_BLOCK);
         }
      } else if(!is_first) {
         switch(t) {
         case 6:
         case 8:
         case 10:
         case 12:
         case 14:
         case 16:
            blocks.add(t - 1);
            break;
         default:
            break;
         }
      }
      return is_first;
   }

   private static boolean isUpdatable(int x, int y, boolean is_first) {
      final int t = board[y * width + x];
      if(t == 0) {
         return true;
      } else if(t == FIRST_BLOCK && is_first) {
         return true;
      } else if(!is_first) {
         switch(t) {
         case 6:
         case 8:
         case 10:
         case 12:
         case 14:
         case 16:
            return !blocks.contains(t - 1);
         default:
            return blocks.contains(t);
         }
      } else {
         return false;
      }
   }

   private static int getScore(int x, int y, boolean is_first) {

      // Try special cases.
      for(int i = 0; i < scores.length; i++) {
         if(scores[i].check(x, y, is_first)) {
            return scores[i].getScore();
         }
      }
      return 1;

      // Other cases.
/*
      int base = 1;
      for(int d = 0; d < 4; d++) {
         final int nx = dirx[d] + x;
         if(nx < 0 || nx >= width) {
            continue;
         }
         final int ny = diry[d] + y;
         if(ny < 0 || ny >= height) {
            continue;
         }
         final int nt = board[ny * width + nx];
         if(nt > 0) {
            ++base;
         }
      }
      int score = 0;
      for(int d = 0; d < 4; d++) {
         final int nx = dirx[d] + x;
         if(nx < 0 || nx >= width) {
            continue;
         }
         final int ny = diry[d] + y;
         if(ny < 0 || ny >= height) {
            continue;
         }
         final int nt = board[ny * width + nx];
         if(nt == KILL_BLOCK) {
            score += base;
            base *= 3;
         }
         if(is_first) {
            switch(nt) {
            case 6:
            case 8:
            case 10:
            case 12:
            case 14:
            case 16:
               score += base;
               base *= 2;
               break;
            default:
               break;
            }
         }
      }
      return score;
*/
   }

}

