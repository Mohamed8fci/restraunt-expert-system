import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Font;
import java.awt.Color;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JLabel;
import javax.swing.ImageIcon;

import jess.JessException;
import jess.Rete;


public class MainJESS extends JFrame {

	private JPanel contentPane;

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					MainJESS frame = new MainJESS();
					frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public MainJESS() {
		setBackground(Color.BLUE);
		setFont(new Font("Rockwell Condensed", Font.BOLD, 22));
		setResizable(false);
		setTitle("restaurant Assistant");
		setLocationRelativeTo(null);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 403, 297);
		contentPane = new JPanel();
		contentPane.setBackground(Color.RED);
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JButton btnOpenTheProject = new JButton("MY Expert System");
		btnOpenTheProject.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				
				new Thread(new Runnable() {
					
					@Override
					public void run() {
						
						Rete r = new Rete();
						try {
							r.batch("restaurant.clp");
						} catch (JessException ex) {
							
							ex.printStackTrace();
						}
					}
				}).start();
				
				
			}
		});
		btnOpenTheProject.setFont(new Font("Rockwell Condensed", Font.BOLD, 22));
		btnOpenTheProject.setBounds(10, 139, 367, 50);
		contentPane.add(btnOpenTheProject);
		
		JButton btnAbout = new JButton("team");
		btnAbout.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				String msg = "JESS Project by:\n1-mohamed Elkordy\n2-mohamed Elhabashy\n3-marko magdy\n4-Abdou shoieb";
				JOptionPane.showMessageDialog(null, msg,"About the project",JOptionPane.INFORMATION_MESSAGE);
			}
		});
		btnAbout.setFont(new Font("Tahoma", Font.BOLD, 11));
		btnAbout.setBounds(153, 234, 89, 23);
		contentPane.add(btnAbout);
		
		JLabel lblNewLabel = new JLabel("");
		lblNewLabel.setIcon(new ImageIcon("D:\\Projects\\Android\\JESS_Project\\Auto-Angry-icon.png"));
		lblNewLabel.setBounds(120, 0, 128, 128);
		contentPane.add(lblNewLabel);
	}
}
