import javax.swing.*;
import java.awt.EventQueue;

public class MainUI extends JFrame {

	public MainUI() {
		initUI();
	}
	
    private void initUI() {
        
        setTitle("Simple example");
        setSize(300, 200);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
    }
    
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
	        
            @Override
            public void run() {
            	MainUI ui = new MainUI();
                ui.setVisible(true);
            }
        });
	}

}
