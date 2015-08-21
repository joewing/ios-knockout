
import java.io.*;
import java.net.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import javax.imageio.*;
import javax.swing.*;
import javax.swing.border.*;

class LevelCell extends JButton implements ActionListener {

   private static final int BLOCK_WIDTH = 32;
   private static final String ball_file = "images/ball.png";
   private static final String block_file = "images/blocks.png";

   private static boolean loaded = false;
   private static int block_count = 0;
   private static ImageIcon ball_image = null;
   private static ImageIcon block_images[] = null;
   private static BlockSelector selector = null;

   private int block_type = 0;

   private static void Load(LevelCell cell) {
      if(!loaded) {
         loaded = true;

         try {

            URL url = cell.getClass().getResource(ball_file);
            BufferedImage temp = ImageIO.read(url);
            Image bi = temp.getScaledInstance(BLOCK_WIDTH, BLOCK_WIDTH,
                                              Image.SCALE_SMOOTH);
            ball_image = new ImageIcon(bi);

            url = cell.getClass().getResource(block_file);
            temp = ImageIO.read(url);
            block_count = (temp.getWidth() / BLOCK_WIDTH) - 1;
            block_images = new ImageIcon[block_count];
            for(int x = 1; x < block_count + 1; x++) {
               BufferedImage sub = temp.getSubimage(x * BLOCK_WIDTH, 0,
                                                    BLOCK_WIDTH, BLOCK_WIDTH);
               block_images[x - 1] = new ImageIcon(sub);
            }

            selector = new BlockSelector();

         } catch(Exception ex) {
            ex.printStackTrace();
         }

      }
   }

   public LevelCell() {
      Load(this);
      setBorder(new LineBorder(Color.BLACK));
      setMinimumSize(new Dimension(BLOCK_WIDTH, BLOCK_WIDTH));
      setPreferredSize(new Dimension(BLOCK_WIDTH, BLOCK_WIDTH));
      addActionListener(this);
      setType(0);
   }

   public void setType(int type) {
      block_type = type;
      if (block_type == 0) {
         setIcon(null);
      } else if(block_type <= block_count) {
         setIcon(block_images[block_type - 1]);
      } else {
         setIcon(ball_image);
      }
   }

   public int getType() {
      return block_type;
   }

   private static final class SelectionListener implements ActionListener {

      public SelectionListener(int t) {
         type = t;
      }

      public void actionPerformed(ActionEvent e) {
         cell.setType(type);
      }

      public void setCell(LevelCell c) {
         cell = c;
      }

      private int type;
      private LevelCell cell;

   }

   private static final class BlockSelector extends JPopupMenu {

      private SelectionListener listeners[];

      public BlockSelector() {

         listeners = new SelectionListener[block_count + 2];
         for(int x = 0; x < listeners.length; x++) {
            final int t = x == block_count + 1 ? 255 : x;
            listeners[x] = new SelectionListener(t);
         }

         JMenuItem item = new JMenuItem("[none]");
         item.addActionListener(listeners[0]);
         add(item);

         for(int x = 0; x < block_count; x++) {
            item = new JMenuItem(block_images[x]);
            item.addActionListener(listeners[x + 1]);
            add(item);
         }

         item = new JMenuItem(ball_image);
         item.addActionListener(listeners[block_count + 1]);
         add(item);

      }

      public void setCell(LevelCell c) {
         for(int x = 0; x < listeners.length; x++) {
            listeners[x].setCell(c);
         }
      }

   }

   public void actionPerformed(ActionEvent e) {

      final Point location = getLocation();
      final int x = location.x;
      final int y = location.y;
      selector.setCell(this);
      selector.show(this, 0, 0);

   }

}

