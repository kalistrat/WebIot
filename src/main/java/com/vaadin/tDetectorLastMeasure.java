package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.MarginInfo;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static com.vaadin.tUsefulFuctions.GetListFromString;

/**
 * Created by kalistrat on 23.01.2017.
 */
public class tDetectorLastMeasure extends HorizontalLayout {

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    TextField LastMeasureField = new TextField("Величина последнего измерения");
    TextField LastMeasureDate = new TextField("Дата последнего измерения");
    Button RefreshMeasure = new Button("Обновить");


    public tDetectorLastMeasure(int eUserDeviceId){

        this.GetLastMeasureData(eUserDeviceId);
        this.setCaption("Последние показания");

        RefreshMeasure.addStyleName(ValoTheme.BUTTON_SMALL);
        RefreshMeasure.setIcon(FontAwesome.REFRESH);
        VerticalLayout bl = new VerticalLayout(new Label(),RefreshMeasure);
        LastMeasureField.setEnabled(false);
        LastMeasureDate.setEnabled(false);
        LastMeasureDate.addStyleName(ValoTheme.TEXTFIELD_SMALL);
        LastMeasureField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        this.addComponent(LastMeasureField);
        this.addComponent(LastMeasureDate);
        this.addComponent(bl);


        this.setSpacing(true);
        this.setIcon(FontAwesome.TASKS);
        //this.addStyleName(ValoTheme.LAYOUT_CARD);
        //this.setMargin(new MarginInfo(true, true, true, true));
        this.setSizeUndefined();

    }

    public void GetLastMeasureData(int iUserDeviceId){
        String iMeasureResult = "";

        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement MeasureResultStmt = conn.prepareCall("{? = call f_get_last_device_measure(?)}");
            MeasureResultStmt.registerOutParameter (1, Types.VARCHAR);
            MeasureResultStmt.setInt(2, iUserDeviceId);
            MeasureResultStmt.execute();
            iMeasureResult = MeasureResultStmt.getString(1);

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();
        }

        List<String> MeasureResultList = GetListFromString(iMeasureResult);

        if (MeasureResultList.size() != 0) {

            this.LastMeasureField.setValue(MeasureResultList.get(3)+" , "+MeasureResultList.get(2));
            this.LastMeasureDate.setValue(MeasureResultList.get(4));

        }

    }
}
