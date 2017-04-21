package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.Property;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.ComboBox;
import com.vaadin.ui.NativeSelect;
import com.vaadin.ui.Notification;
import com.vaadin.ui.VerticalLayout;
import org.vaadin.teemu.VaadinIcons;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static com.vaadin.tUsefulFuctions.GetMarksFromString;

/**
 * Created by kalistrat on 25.01.2017.
 */
public class tPeriodMeasuresLayout extends VerticalLayout {

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    NativeSelect tPeriodCB = new NativeSelect();
    Integer XD;
    Integer YD;
    List<tMark> MarkXList;
    List<tMark> MarkYList;
    List<tMark> XYList = new ArrayList<tMark>();
    Integer tUserDeviceId;
    tGraphLayout GraphDraw;

    public tPeriodMeasuresLayout(int eUserDeviceId){


        this.tUserDeviceId = eUserDeviceId;

        setComboBoxData();

        setListXYMarks(eUserDeviceId,"год",10,"x");
        setListXYMarks(eUserDeviceId,"год",5,"y");
        GetGraphData(eUserDeviceId,"год");


        tPeriodCB.setCaption("Выберите период");
        tPeriodCB.setNullSelectionAllowed(false);


        tPeriodCB.setValue("год");

        tPeriodCB.setImmediate(true);

        tPeriodCB.addValueChangeListener(new Property.ValueChangeListener() {
             @Override
             public void valueChange(Property.ValueChangeEvent e) {
//                 Notification.show("Value changed:",
//                         String.valueOf(e.getProperty().getValue()),
//                         Notification.Type.TRAY_NOTIFICATION);

                 String SelectedPeriod = (String) e.getProperty().getValue();
                 MarkXList.removeAll(MarkXList);
                 MarkYList.removeAll(MarkYList);
                 XYList.removeAll(XYList);

                 setListXYMarks(eUserDeviceId,SelectedPeriod,10,"x");
                 setListXYMarks(eUserDeviceId,SelectedPeriod,5,"y");
                 GetGraphData(eUserDeviceId,SelectedPeriod);
                 tGraphLayout GraphDrawNew  = new tGraphLayout(
                         MarkXList
                         ,MarkYList
                         ,XYList
                         ,GetMeasureUnits(tUserDeviceId)
                 );
                 //addComponent(GraphDraw);

                 replaceComponent(GraphDraw,  GraphDrawNew);
                 GraphDraw = GraphDrawNew;

                 if (XYList.size() == 0){
                         Notification.show("За выбранный период данные отсутствуют",
                         Notification.Type.TRAY_NOTIFICATION);
                 }

             }
         }
        );

        GraphDraw = new tGraphLayout(
        this.MarkXList
        ,this.MarkYList
        ,this.XYList
        ,GetMeasureUnits(this.tUserDeviceId)
        );

        this.setCaption("Показания за ближайший период");
        this.setIcon(VaadinIcons.CHART);
        this.addComponent(tPeriodCB);
        this.addComponent(GraphDraw);

        this.setSpacing(true);
        this.setSizeUndefined();

    }

    public void setComboBoxData(){

        try {
            Class.forName(JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(DB_URL, USER, PASS);

            String PeriodSql = "select g.period_id\n" +
                    ",g.period_code\n" +
                    "from graph_period g";

            PreparedStatement PeriodSqlStmt = Con.prepareStatement(PeriodSql);

            ResultSet PeriodSqlRs = PeriodSqlStmt.executeQuery();

            while (PeriodSqlRs.next()) {
                Integer iPeriodId = PeriodSqlRs.getInt(1);
                String iPeriodCode = PeriodSqlRs.getString(2);
                this.tPeriodCB.addItem(iPeriodCode);
            }
            Con.close();

        } catch (SQLException se3) {
            //Handle errors for JDBC
            se3.printStackTrace();
        } catch (Exception e13) {
            //Handle errors for Class.forName
            e13.printStackTrace();
        }

    }

    public void setListXYMarks(int iUserDeviceId, String iPeriodCode, int iCountMarks, String iAxeName){
        String iMarksStringResult = "";
        Integer iMarksInterval = 0;
        String SqlContent = "";

        if (iAxeName.equals("x")){
            SqlContent = "{call p_make_date_marks(?,?,?,?,?)}";
        } else {
            SqlContent = "{call p_make_double_marks(?,?,?,?,?)}";
        }

        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement XMarksListStmt = conn.prepareCall(SqlContent);
            XMarksListStmt.setInt(1, iUserDeviceId);
            XMarksListStmt.setString(2, iPeriodCode);
            XMarksListStmt.setInt(3, iCountMarks);
            XMarksListStmt.registerOutParameter (4, Types.VARCHAR);
            XMarksListStmt.registerOutParameter (5, Types.INTEGER);
            XMarksListStmt.execute();
            iMarksStringResult = XMarksListStmt.getString(4);
            iMarksInterval = XMarksListStmt.getInt(5);

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();
        }

        if (iAxeName.equals("x")){
            this.MarkXList = GetMarksFromString(iMarksStringResult,"x");
            this.XD = iMarksInterval;
        } else {
            this.MarkYList = GetMarksFromString(iMarksStringResult,"y");
            this.YD = iMarksInterval;
        }

    }

    public void GetGraphData(int iUserDeviceId, String iPeriodCode){

        try {
            Class.forName(JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(DB_URL, USER, PASS);

            String GraphSql = "select TIMESTAMPDIFF(second,f_get_graph_min_date_mark(?,?),udm.measure_date) x\n" +
                    ",round(udm.measure_value) y\n" +
                    "from user_device_measures udm\n" +
                    "where udm.measure_date <= (\n" +
                    "select max(uu.measure_date)\n" +
                    "from user_device_measures uu\n" +
                    "where uu.user_device_id=?\n" +
                    ")\n" +
                    "and udm.measure_date >= f_get_graph_min_date(?,?)\n" +
                    "and udm.user_device_id=?\n" +
                    "order by udm.measure_date";

            PreparedStatement GraphSqlStmt = Con.prepareStatement(GraphSql);

            GraphSqlStmt.setInt(1, iUserDeviceId);
            GraphSqlStmt.setString(2, iPeriodCode);
            GraphSqlStmt.setInt(3, iUserDeviceId);
            GraphSqlStmt.setInt(4, iUserDeviceId);
            GraphSqlStmt.setString(5, iPeriodCode);
            GraphSqlStmt.setInt(6, iUserDeviceId);

            ResultSet GraphSqlRs = GraphSqlStmt.executeQuery();

            while (GraphSqlRs.next()) {
                this.XYList.add(new tMark(GraphSqlRs.getInt(1),GraphSqlRs.getInt(2),""));
            }
            Con.close();

        } catch (SQLException se3) {
            //Handle errors for JDBC
            se3.printStackTrace();
        } catch (Exception e13) {
            //Handle errors for Class.forName
            e13.printStackTrace();
        }

    }

    public String GetMeasureUnits(int iUserDeviceId){
        String UnitSymbol = "";

        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement UnitSymStmt =  conn.prepareCall("{? = call f_get_unit_sym(?)}");
            UnitSymStmt.registerOutParameter (1, Types.INTEGER);
            UnitSymStmt.setInt(2,iUserDeviceId);
            UnitSymStmt.execute();
            UnitSymbol = UnitSymStmt.getString(1);

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();
        }


        return UnitSymbol;
    }

}
