
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.*;
import java.io.*;
import java.math.*;

class LevelEditor {

   public static final int LEVEL_HEIGHT = 10;
   public static final int LEVEL_WIDTH = 13;

   private JFrame frame;
   private LevelCell cells[];
   private String current_path = null;

   public LevelEditor() {

      frame = new JFrame("Knockout Level Editor");
      frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
      frame.setLayout(new GridLayout(LEVEL_HEIGHT, LEVEL_WIDTH));

      cells = new LevelCell[LEVEL_HEIGHT * LEVEL_WIDTH];
      for(int y = 0; y < LEVEL_HEIGHT; y++) {
         for(int x = 0; x < LEVEL_WIDTH; x++) {
            final int index = y * LEVEL_WIDTH + x;
            cells[index] = new LevelCell();
            frame.add(cells[index]);
         }
      }

      JMenuBar bar = new JMenuBar();
      frame.setJMenuBar(bar);

      JMenu menu = new JMenu("File");
      bar.add(menu);

      JMenuItem item = new JMenuItem("Open");
      item.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            JFileChooser chooser = new JFileChooser(current_path);
            int rc = chooser.showOpenDialog(frame);
            if(rc == JFileChooser.APPROVE_OPTION) {
               current_path = chooser.getSelectedFile().getParent();
               try {
                  File f = chooser.getSelectedFile();
                  FileInputStream stream = new FileInputStream(f);
                  read(stream);
                  stream.close();
               } catch(Exception ex) {
                  ex.printStackTrace();
               }
            }
         }
      });
      menu.add(item);

      item = new JMenuItem("Save");
      item.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            if(!validateLevel()) {
               return;
            }
            JFileChooser chooser = new JFileChooser(current_path);
            int rc = chooser.showSaveDialog(frame);
            if(rc == JFileChooser.APPROVE_OPTION) {
               current_path = chooser.getSelectedFile().getParent();
               try {
                  File f = chooser.getSelectedFile();
                  PrintWriter writer = new PrintWriter(f);
                  write(writer);
                  writer.close();
               } catch(Exception ex) {
                  ex.printStackTrace();
               }
            }
         }
      });
      menu.add(item);

      JSeparator sep = new JSeparator();
      menu.add(sep);

      item = new JMenuItem("Exit");
      item.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            System.exit(0);
         }
      });
      menu.add(item);

      menu = new JMenu("Level");
      bar.add(menu);

      item = new JMenuItem("Validate");
      item.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            validateLevel();
         }
      });
      menu.add(item);

      sep = new JSeparator();
      menu.add(sep);

      item = new JMenuItem("Clear");
      item.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            clear();
         }
      });
      menu.add(item);

      item = new JMenuItem("Generate");
      item.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            generateLevel();
         }
      });
      menu.add(item);

   }

   public void show() {
      frame.pack();
      frame.setVisible(true);
   }

   public void write(PrintWriter wr) {
      int[] temp = new int[LEVEL_WIDTH * LEVEL_HEIGHT];
      for(int x = 0; x < temp.length; x++) {
         temp[x] = cells[x].getType();
      }
      LevelIO.write(temp, wr);
   }

   public void read(InputStream is) {
      int[] temp = LevelIO.read(is);
      for(int x = 0; x < temp.length; x++) {
         cells[x].setType(temp[x]);
      }
   }

   public boolean validateLevel() {

      // Make sure the ball is in exactly one position.
      int ball_count = 0;
      for(int x = 0; x < cells.length; x++) {
         if(cells[x].getType() == 255) {
            ++ball_count;
         }
      }
      if(ball_count != 1) {
         ErrorDialog dialog = new ErrorDialog(frame);
         dialog.setMessage("ball must be specified exactly once.");
         dialog.setVisible(true);
         return false;
      }

      int[] board = new int[cells.length];
      for(int x = 0; x < board.length; x++) {
         board[x] = cells[x].getType();
      }
      final int score = LevelStats.computeScore(board);
      System.out.println("Score: " + Integer.toString(score));

      return score != Integer.MAX_VALUE;

   }

   public void clear() {
      for(int x = 0; x < cells.length; x++) {
         cells[x].setType(0);
      }
   }

   public void generateLevel() {

      for(;;) {

         for(int x = 0; x < cells.length; x++) {
            int t = (int)(Math.random() * 20);
            if(t > 16) {
               t = 0;
            }
            cells[x].setType(t);
         }
         cells[(int)(Math.random() * LEVEL_WIDTH * LEVEL_HEIGHT)].setType(255);

         if(validateLevel()) {
            break;
         }

      }

   }

}

