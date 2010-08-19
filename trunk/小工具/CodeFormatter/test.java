package com.zte.ums.womcn.wsf.cm.equip;
/**
 * <p>文件名称:RackFrameJPanel.java   </p>
 * <p>文件描述: 本文件完成机架接入设备维护框架的面板，完成所有机架图新的布局方式</p>
 * <p>版权所有: 版权所有(C)2007-2010</p>
 * <p>公    司: 深圳市中兴通讯股份有限公司</p>
 * <p>内容摘要: 无</p>
 * <p>其他说明: 无</p>
 * <p>创建日期：2007-7-7</p>
 * <p>完成日期：2005-7-7</p>
 * <p>修改记录1: // 修改历史记录，包括修改日期、修改者及修改内容</p>
 * <pre>
 *    修改日期：
 *    版 本 号：
 *    修 改 人：
 *    修改内容：
 * </pre>
 * <p>修改记录2：…</p>
 * @version 1.0
 * @author fengxi
 */

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Image;
import java.awt.Insets;
import java.awt.Toolkit;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.ObjectMessage;
import javax.swing.JPanel;
import java.awt.event.ActionEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.FilteredImageSource;
import java.awt.image.ImageFilter;
import java.awt.image.ImageProducer;
import javax.swing.BorderFactory;
import javax.swing.DefaultListModel;
import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JScrollPane;
import javax.swing.ListSelectionModel;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import com.zte.ums.cap.api.IRackChartToolBar;
import com.zte.ums.csp.api.mml.common.ICmdDataReader;
import com.zte.ums.csp.api.mml.common.ICmdResponse;
import com.zte.ums.csp.api.mml.common.IComplexParaValue;
import com.zte.ums.csp.api.mml.common.IParaValue;
import com.zte.ums.csp.mml.common.CLISException;
import com.zte.ums.csp.mml.common.MMLConst;
import com.zte.ums.uep.api.ExtensionAccess;
import com.zte.ums.uep.api.ServiceAccess;
import com.zte.ums.uep.api.pal.cm.parameter.ApplicationException;
import com.zte.ums.uep.api.pal.equip.entity.Rack;
import com.zte.ums.uep.api.pfl.mif.entity.commonuse.DN;
import com.zte.ums.uep.api.psl.hierarchy.GetNodeException;
import com.zte.ums.uep.api.psl.jmswrapper.AsyncReceiver;
import com.zte.ums.uep.api.psl.jmswrapper.Constants;
import com.zte.ums.uep.api.psl.jmswrapper.MessageService;
import com.zte.ums.uep.api.util.DebugPrn;
import com.zte.ums.uep.api.util.I18n;
import com.zte.ums.uep.gui.component.CloseListener;
import com.zte.ums.uep.gui.component.ZXClosableTabbedPane;
import com.zte.ums.uep.gui.component.util.RGBSharpener;
import com.zte.ums.uep.gui.component.util.UIToolKit;
import com.zte.ums.womcn.api.cm.wsf.rackchart.RackCommonConst;
import com.zte.ums.womcn.wsf.cm.equip.common.EquipCommonConst;
import com.zte.ums.womcn.wsf.cm.equip.phyres.RackMapObject;
import com.zte.ums.womcn.wsf.cm.equip.util.RackData;
import com.zte.ums.womcn.wsf.cm.equip.util.Universal;


public class  RackFrameJPanel extends JPanel  {
	private ZXClosableTabbedPane racktabs = new ZXClosableTabbedPane(true);
	private CloseListener rackcloseListener = null;
	private ChangeListener rackChangeListener = null;
	//private JComboBox rackNoBox = new JComboBox(); 
	private DefaultListModel listModel = new DefaultListModel();
	private JList rackNoBox = new JList(listModel);
	
	private MouseAdapter rackNoAction = null;
	public AbstractGetRackInfo getRackInfo = new AbstractGetRackInfo();
	private int serverID = 0;
	private int bureaNo = 0;
	private static AsyncReceiver receiver = null;
	private final static DebugPrn DMSG = new DebugPrn(RackFrameJPanel.class.getName());
	private JPanel rackPanel = null;
	public static Object[] toolBarObject = null;
	/**
	 * 面板构造方法，目的是完成面板的布局和把需要的参数传入
	 * @param aserverID  服务器ID号
	 * @param bureano    交换局局号
	 */
	public RackFrameJPanel(int aserverID, int abureaNo) {
		this.serverID= aserverID;
		this.bureaNo = abureaNo;
		racktabs.setTabWithClosedButton(true);
		racktabs.setTabType(ZXClosableTabbedPane.FUNCTION_VIEW);
		rackNoAction = new RackNoAction(this.serverID,this.bureaNo);
		setLayout();
	}
	
	private void setLayout()
	{
	    this.setLayout(new GridBagLayout()
	    );
	    rackPanel = getRackTopPanel();
	    JPanel toolPane = new JPanel(); //工具panel
	    toolPane.setLayout(new BorderLayout());
        JPanel alarmPanel = new AlarmPanel();
        alarmPanel.setMinimumSize(new Dimension(70,250));
        rackPanel.setMinimumSize(new Dimension(
        							70,
        							350)
        							);
        
	    JPanel panel = new JPanel();
	    JScrollPane scrPanel = new JScrollPane(panel);
	    panel.setPreferredSize(new Dimension(80, 500));
	    panel.setMinimumSize(new Dimension(80, 500));
	    scrPanel.setPreferredSize(new Dimension(90, 500));
	    scrPanel.setMinimumSize(new Dimension(90, 500));
	    panel.setLayout(new GridBagLayout());
	    panel.add(rackPanel, new GridBagConstraints(0, 0, 1, 1, 0, 0.4, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(6, 0, 6, 0), 0, 0));
	    panel.add(alarmPanel, new GridBagConstraints(0, 1, 1, 1, 0, 0.6, GridBagConstraints.SOUTH,
                GridBagConstraints.BOTH, new Insets(6, 0, 6, 0), 0, 0));
	     
	    JPanel totalPanel = new JPanel();
	    totalPanel.setLayout(new GridBagLayout());
	    totalPanel.add(toolPane, new GridBagConstraints(0, 0, 1, 1, 0, 0.03, GridBagConstraints.NORTH,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
	    totalPanel.add(scrPanel, new GridBagConstraints(0, 1, 1, 1, 0, 0.97, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
	    
	    this.add(totalPanel, new GridBagConstraints(0, 0, 1, 1, 0.04, 1, GridBagConstraints.WEST ,
                GridBagConstraints.BOTH, new Insets(6, 3, 3, 2), 0, 0)); 
	    
	    this.add(racktabs, new GridBagConstraints(1, 0, 1, 2, 0.96, 1, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(1, 3, 3, 6), 0, 0));
        
		initRackTabbes();
		initRackNoBox();
		
		//调用扩展点
        getExts();
        IRackChartToolBar iRackChartToolBar = null;
        for (int i = 0; i < toolBarObject.length; i++)
        {
            iRackChartToolBar = (IRackChartToolBar)toolBarObject[0];
            JComponent toolBar = iRackChartToolBar.getRackChartToolBar(bureaNo, getRackInfo.rackGraph);
		    if(toolBar != null){ 
		       toolPane.add(toolBar, BorderLayout.CENTER);
		    }
        }
		
	}
    
}