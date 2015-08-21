
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

class ErrorDialog extends JDialog {

   private Frame owner;
   private JLabel label;

   public ErrorDialog(Frame frame) {

      super(frame, "Error", true);
      owner = frame;
      setLayout(new GridLayout(2, 1));

      label = new JLabel();
      add(label);

      JButton ok = new JButton("OK");
      ok.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            setVisible(false);
         }
      });
      add(ok);
      
   }

   public void setMessage(String msg) {
      label.setText("Error: " + msg);
   }

   public void setVisible(boolean v) {
      if(v) {
         pack();
         final Dimension dim = getSize();
         final Point ploc = owner.getLocationOnScreen();
         final Dimension pdim = owner.getSize();
         final int x = ploc.x - dim.width / 2 + pdim.width / 2;
         final int y = ploc.y - dim.height / 2 + pdim.height / 2;
         setLocation(x, y);
      }
      super.setVisible(v);
   }

}

