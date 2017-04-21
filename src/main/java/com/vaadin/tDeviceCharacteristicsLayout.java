package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static com.vaadin.tUsefulFuctions.GetListFromString;

/**
 * Created by kalistrat on 24.01.2017.
 */
public class tDeviceCharacteristicsLayout extends HorizontalLayout {

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    //TextField DeviceNameField = new TextField("Наименование устройства");
    //TextField DeviceTypeField = new TextField("Тип устройства");
    IndexedContainer DeviceDataContainer;


    public tDeviceCharacteristicsLayout(int eUserDeviceId){

        this.GetDeviceData(eUserDeviceId);
        this.setCaption("Данные об устройстве");

        Table dTable = new Table();
        dTable.setColumnHeader(1, "Наименование устройства");
        dTable.setColumnHeader(2, "Тип устройства");
        dTable.setColumnHeader(3, "Доступность");

        dTable.setContainerDataSource(this.DeviceDataContainer);
        dTable.setPageLength(this.DeviceDataContainer.size());


        this.addComponent(dTable);


        this.setSpacing(true);
        this.setIcon(VaadinIcons.FILE_TABLE);
        //this.addStyleName(ValoTheme.LAYOUT_CARD);
        //this.setMargin(true);
        this.setSizeUndefined();



    }

    public void GetDeviceData(int iUserDeviceId){
        String iDeviceDataResult = "";
        IndexedContainer iDeviceData = new IndexedContainer();

        iDeviceData.addContainerProperty(1, String.class, null);
        iDeviceData.addContainerProperty(2, String.class, null);
        iDeviceData.addContainerProperty(3, Label.class, null);



        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement DeviceDataStmt = conn.prepareCall("{? = call f_get_device_data(?)}");
            DeviceDataStmt.registerOutParameter (1, Types.VARCHAR);
            DeviceDataStmt.setInt(2, iUserDeviceId);
            DeviceDataStmt.execute();
            iDeviceDataResult = DeviceDataStmt.getString(1);

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();
        }

        List<String> DeviceDataList = GetListFromString(iDeviceDataResult);

        if (DeviceDataList.size() != 0) {

//            this.DeviceNameField.setValue(DeviceDataList.get(0));
//            this.DeviceTypeField.setValue(DeviceDataList.get(1));

            Item newItem = iDeviceData.getItem(iDeviceData.addItem());

            newItem.getItemProperty(1).setValue(DeviceDataList.get(0));
            newItem.getItemProperty(2).setValue(DeviceDataList.get(1));
            Label AccLabel = new Label();
            AccLabel.setContentMode(ContentMode.HTML);
            AccLabel.setValue(VaadinIcons.CHECK_CIRCLE.getHtml());
            newItem.getItemProperty(3).setValue(AccLabel);

        }

        this.DeviceDataContainer = iDeviceData;

    }
}
