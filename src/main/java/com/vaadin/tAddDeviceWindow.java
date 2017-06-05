package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.MarginInfo;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;

/**
 * Created by kalistrat on 17.05.2017.
 */
public class tAddDeviceWindow extends Window {

    Button SaveButton;
    Button CancelButton;
    TextField EditTextField;
    tTreeContentLayout iTreeContentLayout;
    int iLeafId;

    int iNewTreeId;
    int iNewLeafId;
    int iNewUserDeviceId;
    String iNewIconCode;

    NativeSelect DeviceActionType;
    String LastActionTypeValue;
    NativeSelect MqttSelect;
    //String LastMqttServerValue;

    public tAddDeviceWindow(int eLeafId
            ,tTreeContentLayout eParentContentLayout
    ){
        iLeafId = eLeafId;
        iTreeContentLayout = eParentContentLayout;

        iNewTreeId = 0;
        iNewLeafId = 0;


        this.setIcon(VaadinIcons.PLUG);
        this.setCaption(" Добавление нового устройства");

        EditTextField = new TextField("Наименование устройства :");
        EditTextField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        DeviceActionType = new NativeSelect("Тип устройства :");
        getActionTypeData();
        DeviceActionType.setNullSelectionAllowed(false);
        DeviceActionType.select(LastActionTypeValue);
        DeviceActionType.addStyleName("SelectFont");

        MqttSelect = new NativeSelect("Доступный mqtt-сервер :");
        getMqttData(iTreeContentLayout.iUserLog);
        MqttSelect.setNullSelectionAllowed(false);
        MqttSelect.select("общий незащищённый");
        MqttSelect.addStyleName("SelectFont");

        SaveButton = new Button("Сохранить");

        SaveButton.setData(this);
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.setIcon(FontAwesome.SAVE);
        SaveButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

                String sErrorMessage = "";
                String sFieldValue = EditTextField.getValue();

                if (sFieldValue == null){
                    sErrorMessage = "Наименование устройства не задано\n";
                }

                if (sFieldValue.equals("")){
                    sErrorMessage = sErrorMessage + "Наименование устройства не задано\n";
                }

                if (sFieldValue.length() > 30){
                    sErrorMessage = sErrorMessage + "Длина наименования превышает 30 символов\n";
                }

                if (tUsefulFuctions.fIsLeafNameBusy(iTreeContentLayout.iUserLog,sFieldValue) > 0){
                    sErrorMessage = sErrorMessage + "Указанное наименование уже используется. Введите другое.\n";
                }

                if (!tUsefulFuctions.isSubscriberExists()) {

                    sErrorMessage = sErrorMessage + "Сервер подписки недоступен\n";

                }

                if (!sErrorMessage.equals("")){
                    Notification.show("Ошибка сохранения:",
                            sErrorMessage,
                            Notification.Type.TRAY_NOTIFICATION);
                } else {


                       addUserDevice(
                                iLeafId//int qParentLeafId
                                , sFieldValue//String qDeviceName
                                , iTreeContentLayout.iUserLog//String qUserLog
                                , (String) DeviceActionType.getValue() //String qActionTypeName
                                , (String) MqttSelect.getValue() //String qMqttServerName
                        );

                        String addSubsribeRes = tUsefulFuctions.updateDeviceMqttLogger(
                                iNewUserDeviceId
                                , iTreeContentLayout.iUserLog
                                , "add"
                        );

                        Item newItem = iTreeContentLayout.itTree.TreeContainer.addItem(iNewLeafId);
                        newItem.getItemProperty(1).setValue(iNewTreeId);
                        newItem.getItemProperty(2).setValue(iNewLeafId);
                        newItem.getItemProperty(3).setValue(iLeafId);
                        newItem.getItemProperty(4).setValue(sFieldValue);
                        newItem.getItemProperty(5).setValue(iNewIconCode);
                        newItem.getItemProperty(6).setValue(iNewUserDeviceId);
                        newItem.getItemProperty(7).setValue((String) DeviceActionType.getValue());

                        iTreeContentLayout.itTree.TreeContainer.setParent(iNewLeafId, iLeafId);

                        if (iNewIconCode.equals("FOLDER")) {
                            iTreeContentLayout.itTree.setItemIcon(iNewLeafId, VaadinIcons.FOLDER);
                        }
                        if (iNewIconCode.equals("TACHOMETER")) {
                            iTreeContentLayout.itTree.setItemIcon(iNewLeafId, FontAwesome.TACHOMETER);
                        }
                        if (iNewIconCode.equals("AUTOMATION")) {
                            iTreeContentLayout.itTree.setItemIcon(iNewLeafId, VaadinIcons.AUTOMATION);
                        }

                        iTreeContentLayout.tTreeContentLayoutRefresh(iLeafId, 0);
                        iTreeContentLayout.itTree.expandItem(iLeafId);

                        if (!addSubsribeRes.equals("")) {
                            Notification.show("Устройство добавлено c ошибкой",
                                    addSubsribeRes,
                                    Notification.Type.TRAY_NOTIFICATION);
                            UI.getCurrent().removeWindow((tAddDeviceWindow) clickEvent.getButton().getData());
                        } else {

                            Notification.show("Устройство добавлено!",
                                    null,
                                    Notification.Type.TRAY_NOTIFICATION);
                            UI.getCurrent().removeWindow((tAddDeviceWindow) clickEvent.getButton().getData());

                        }
                    }


            }
        });

        CancelButton = new Button("Отменить");

        CancelButton.setData(this);
        CancelButton.addStyleName(ValoTheme.BUTTON_SMALL);
        CancelButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                UI.getCurrent().removeWindow((tAddDeviceWindow) clickEvent.getButton().getData());
            }
        });

        HorizontalLayout ButtonsLayout = new HorizontalLayout(
                SaveButton
                ,CancelButton
        );

        ButtonsLayout.setSizeUndefined();
        ButtonsLayout.setSpacing(true);

        FormLayout IniDevParamLayout = new FormLayout(
                EditTextField
                ,DeviceActionType
                ,MqttSelect
        );
        IniDevParamLayout.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        IniDevParamLayout.setSizeUndefined();
        IniDevParamLayout.setMargin(false);

        VerticalLayout MessageLayout = new VerticalLayout(
                IniDevParamLayout
        );
        MessageLayout.setSpacing(true);
        MessageLayout.setWidth("520px");
        MessageLayout.setHeightUndefined();
        MessageLayout.setMargin(new MarginInfo(true,false,true,false));
        MessageLayout.setComponentAlignment(IniDevParamLayout, Alignment.MIDDLE_CENTER);
        MessageLayout.addStyleName(ValoTheme.LAYOUT_CARD);

        VerticalLayout WindowContentLayout = new VerticalLayout(
                MessageLayout
                ,ButtonsLayout
        );
        WindowContentLayout.setSizeUndefined();
        WindowContentLayout.setSpacing(true);
        WindowContentLayout.setMargin(true);
        WindowContentLayout.setComponentAlignment(ButtonsLayout, Alignment.BOTTOM_CENTER);

        this.setContent(WindowContentLayout);
        this.setSizeUndefined();
        this.setModal(true);
        //this.addStyleName(ValoTheme.WINDOW_BOTTOM_TOOLBAR);
    }

    public void getActionTypeData(){

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select at.action_type_name\n" +
                    "from action_type at";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);

            ResultSet DataRs = DataStmt.executeQuery();

            while (DataRs.next()) {
                LastActionTypeValue = DataRs.getString(1);
                DeviceActionType.addItem(DataRs.getString(1));
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

//    public void getMqttData(){
//
//        try {
//            Class.forName(tUsefulFuctions.JDBC_DRIVER);
//            Connection Con = DriverManager.getConnection(
//                    tUsefulFuctions.DB_URL
//                    , tUsefulFuctions.USER
//                    , tUsefulFuctions.PASS
//            );
//
//            String DataSql = "select concat(concat(s.server_ip,':'),s.server_port)\n" +
//                    "from mqtt_servers s";
//
//            PreparedStatement MqttDataStmt = Con.prepareStatement(DataSql);
//
//            ResultSet MqttDataRs = MqttDataStmt.executeQuery();
//
//            while (MqttDataRs.next()) {
//                LastMqttServerValue = MqttDataRs.getString(1);
//                MqttSelect.addItem(MqttDataRs.getString(1));
//            }
//
//
//            Con.close();
//
//        } catch (SQLException se3) {
//            //Handle errors for JDBC
//            se3.printStackTrace();
//        } catch (Exception e13) {
//            //Handle errors for Class.forName
//            e13.printStackTrace();
//        }
//    }

        public void getMqttData(String qUserLog){

            MqttSelect.addItem("общий незащищённый");

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement MqttDataStmt = Con.prepareCall("{? = call f_get_user_account_type(?)}");
            MqttDataStmt.registerOutParameter(1,Types.VARCHAR);
            MqttDataStmt.setString(2,qUserLog);
            MqttDataStmt.execute();
            String UserAccountType  = MqttDataStmt.getString(1);

            if (UserAccountType.equals("PRIVILEGED")) {
                MqttSelect.addItem("общий защищённый");
                MqttSelect.addItem("отдельный незащищённый");
                MqttSelect.addItem("отдельный защищённый");
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

    public void addUserDevice(
        int qParentLeafId
        , String qDeviceName
        , String qUserLog
        , String qActionTypeName
        , String qMqttServerType
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement addDeviceStmt = Con.prepareCall("{call p_add_user_device(?, ?, ?, ?, ?, ?, ?, ?, ?)}");
            addDeviceStmt.setInt(1, qParentLeafId);
            addDeviceStmt.setString(2, qDeviceName);
            addDeviceStmt.setString(3, qUserLog);
            addDeviceStmt.setString(4, qActionTypeName);
            addDeviceStmt.setString(5, qMqttServerType);
            addDeviceStmt.registerOutParameter(6, Types.INTEGER);
            addDeviceStmt.registerOutParameter(7, Types.INTEGER);
            addDeviceStmt.registerOutParameter(8, Types.VARCHAR);
            addDeviceStmt.registerOutParameter(9, Types.INTEGER);

            addDeviceStmt.execute();

            iNewTreeId = addDeviceStmt.getInt(6);
            iNewLeafId = addDeviceStmt.getInt(7);
            iNewIconCode = addDeviceStmt.getString(8);
            iNewUserDeviceId = addDeviceStmt.getInt(9);

            Con.close();


        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
            //return "Ошибка JDBC";
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
            //return "Ошибка Class.forName";
        }

    }
}
