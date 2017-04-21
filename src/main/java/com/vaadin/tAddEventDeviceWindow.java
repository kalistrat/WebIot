package com.vaadin;

import com.vaadin.data.Container;
import com.vaadin.data.Item;
import com.vaadin.data.Property;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.vaadin.tUsefulFuctions.*;

/**
 * Created by kalistrat on 20.02.2017.
 */
public class tAddEventDeviceWindow extends Window {

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    TextField tEventName;
    tEventConditionLayout tEventCriteriaAddLayout;
    NativeSelect tCallDeviceSelect;
    NativeSelect tCallMethodDeviceSelect;
    int tUserDeviceId;
    VerticalLayout tDeviceMethodLayout = new VerticalLayout();
    Integer tRelativeUserDeviceId;
    List<tIdCaption> tMethodDeviceList =  new ArrayList<tIdCaption>();
    List<tIdCaption> tDeviceList = new ArrayList<tIdCaption>();

    Button tSaveButton;
    Button tCancelButton;

    public tAddEventDeviceWindow(int eUserDeviceId,tEventsControlDevicesLayout iEVCLayout){

        this.setModal(true);
        this.setIcon(VaadinIcons.CONNECT);
        this.setCaption("  Добавление нового события");

        tUserDeviceId = eUserDeviceId;

        tEventName = new TextField("Наименование события");
        tEventName.addStyleName(ValoTheme.TEXTFIELD_SMALL);
        tEventCriteriaAddLayout = new tEventConditionLayout();


        fillCallDeviceSelect(this.tUserDeviceId);
        this.tCallDeviceSelect = new NativeSelect("Вызываемое устройство"
        ,GetCaptionList(this.tDeviceList));
        this.tCallDeviceSelect.setValue(GetCaptionList(this.tDeviceList).get(0));
        tRelativeUserDeviceId = this.tDeviceList.get(0).tId;

        fillCallDeviceMethodSelect(tRelativeUserDeviceId);
        this.tCallMethodDeviceSelect = new NativeSelect("Вызываемый метод"
        ,GetCaptionList(this.tMethodDeviceList));
        this.tCallMethodDeviceSelect.setValue(GetCaptionList(this.tMethodDeviceList).get(0));

        this.tCallDeviceSelect.setNullSelectionAllowed(false);
        this.tCallMethodDeviceSelect.setNullSelectionAllowed(false);

        tDeviceMethodLayout.setSpacing(true);
        tDeviceMethodLayout.addComponent(this.tCallDeviceSelect);
        tDeviceMethodLayout.addComponent(this.tCallMethodDeviceSelect);

        tCallDeviceSelect.addValueChangeListener(new Property.ValueChangeListener() {
              @Override
              public void valueChange(Property.ValueChangeEvent e) {

                  String RelativeUserDeviceName = (String) e.getProperty().getValue();
                  tRelativeUserDeviceId = GetIdByCaption(tDeviceList,RelativeUserDeviceName);
                  tCallMethodDeviceSelect.removeAllItems();
                  fillCallDeviceMethodSelect(tRelativeUserDeviceId);
                  tCallMethodDeviceSelect.addItems(GetCaptionList(tMethodDeviceList));
                  tCallMethodDeviceSelect.setValue(GetCaptionList(tMethodDeviceList).get(0));
//                        Notification.show("выбранное значение:",
//                                String.valueOf(e.getProperty().getValue()),
//                        Notification.Type.TRAY_NOTIFICATION);
              }
          }
        );
        tSaveButton = new Button("Сохранить");
        tSaveButton.setIcon(FontAwesome.SAVE);
        tSaveButton.setData(this);

        tSaveButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                Integer iRelationDeviceId = GetIdByCaption(tDeviceList,(String) tCallDeviceSelect.getValue());
                Integer iRelationDeviceMethodId = GetIdByCaption(tMethodDeviceList,(String) tCallMethodDeviceSelect.getValue());
                String iEventCriteria = (String) tEventCriteriaAddLayout.TypeCriteriaSelect.getValue();
                String iMaxFieldValue = tEventCriteriaAddLayout.CriteriaValueLayout.sMaxField.getValue();
                String iMinFieldValue = tEventCriteriaAddLayout.CriteriaValueLayout.sMinField.getValue();
                String iEventName = tEventName.getValue();
                String sErrorMessage = "";


                if (iEventName.equals("")){
                    sErrorMessage = "Не заполнено поле \"Наименование события\"\n";
                }

                if (iEventCriteria.equals("интервал значений")) {
                    if ((iMaxFieldValue == null) || (iMinFieldValue == null)) {
                        sErrorMessage = sErrorMessage + "Не заполнены поля \"От\" и \"До\"\n";
                    }
                }

                if (iEventCriteria.equals("интервал значений")) {
                    if ((iMaxFieldValue != null) && (iMinFieldValue != null)) {
                        Double doMaxVal = Double.parseDouble(iMaxFieldValue.replace(",","."));
                        Double doMinVal = Double.parseDouble(iMinFieldValue.replace(",","."));
                        if (doMaxVal <= doMinVal) {
                            sErrorMessage = sErrorMessage + "Минимальное значение больше или равно максимальному";
                        }
                    }
                }

                if (iEventCriteria.equals("полуинтервал значений >")) {
                    if (iMinFieldValue == null) {
                        sErrorMessage = sErrorMessage + "Не заполнено поле \"От\"\n";
                    }
                }

                if (iEventCriteria.equals("полуинтервал значений <")) {
                    if (iMaxFieldValue == null) {
                        sErrorMessage = sErrorMessage + "Не заполнено поле \"До\"\n";
                    }
                }

                if (iEventCriteria.equals("фиксированное значение =")) {
                    if (iMaxFieldValue == null) {
                        sErrorMessage = sErrorMessage + "Не заполнено поле \"Равно\"\n";
                    }
                }

                if (!sErrorMessage.equals("")){
                    Notification.show("Ошибка добавления события:",
                            sErrorMessage,
                    Notification.Type.TRAY_NOTIFICATION);
                } else {
                    Double dMaxVal = ParseDouble(iMaxFieldValue);
                    Double dMinVal = ParseDouble(iMinFieldValue);
                    AddEventDeviceCondition(
                             iRelationDeviceId
                            ,iRelationDeviceMethodId
                            ,iEventCriteria
                            ,dMaxVal
                            ,dMinVal
                            ,iEventName
                    );
                    iEVCLayout.refreshEventsContainer(tUserDeviceId);
                    Notification.show("Событие успешно добавлено!",
                            null,
                            Notification.Type.TRAY_NOTIFICATION);
                    ((Window) clickEvent.getButton().getData()).close();

                }

            }
        });

        tCancelButton = new Button("Отменить");
        tCancelButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        tCancelButton.setData(this);

        tCancelButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                ((Window) clickEvent.getButton().getData()).close();
            }
        });

        HorizontalLayout ButtonsLayout = new HorizontalLayout(
                tSaveButton
                ,tCancelButton
        );
        ButtonsLayout.setSpacing(true);

        VerticalLayout ContentWindowLayout = new VerticalLayout(
                tEventName
                ,tEventCriteriaAddLayout
                ,tDeviceMethodLayout
                ,ButtonsLayout
        );

        this.setModal(true);
        ContentWindowLayout.setMargin(true);
        ContentWindowLayout.setSpacing(true);
        this.setContent(ContentWindowLayout);


    }

    public void fillCallDeviceSelect(int iUserDeviceId){

        this.tDeviceList.removeAll(this.tDeviceList);

        try {
            Class.forName(JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(DB_URL, USER, PASS);
            String UserDevicesSql;

                UserDevicesSql = "select ud.user_device_id\n" +
                        ",ud.device_user_name\n" +
                        "from user_device ud\n" +
                        "where ud.user_id = (\n" +
                        "select uu.user_id\n" +
                        "from user_device uu\n" +
                        "where uu.user_device_id = ?\n" +
                        ")\n" +
                        "and ud.user_device_id != ?";

            PreparedStatement UserDevicesStmt = Con.prepareStatement(UserDevicesSql);
            UserDevicesStmt.setInt(1, iUserDeviceId);
            UserDevicesStmt.setInt(2, iUserDeviceId);

            ResultSet UserDevicesRs = UserDevicesStmt.executeQuery();

            while (UserDevicesRs.next()) {
                Integer cId = UserDevicesRs.getInt(1);
                String cName = UserDevicesRs.getString(2);
                this.tDeviceList.add(new tIdCaption(cId,cName));
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

    public void fillCallDeviceMethodSelect(int iUserDeviceId){

        this.tMethodDeviceList.removeAll(this.tMethodDeviceList);

        try {
            Class.forName(JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(DB_URL, USER, PASS);
            String UserDevicesSql;

            UserDevicesSql = "select dem.device_method_id\n" +
                    ",dem.method_name\n" +
                    "from user_device ud\n" +
                    "join device_method dem on dem.device_id=ud.device_id\n" +
                    "where ud.user_device_id = ?";

            PreparedStatement UserDevicesStmt = Con.prepareStatement(UserDevicesSql);
            UserDevicesStmt.setInt(1, iUserDeviceId);
            ResultSet UserDevicesRs = UserDevicesStmt.executeQuery();

            while (UserDevicesRs.next()) {

                Integer cId = UserDevicesRs.getInt(1);
                String cName = UserDevicesRs.getString(2);
                this.tMethodDeviceList.add(new tIdCaption(cId,cName));

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

    public void AddEventDeviceCondition(
    Integer eRelationDeviceId
    ,Integer eRelationDeviceMethodId
    ,String eEventCriteria
    ,Double eMaxFieldValue
    ,Double eMinFieldValue
    ,String eEventName
    ){

        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement DeviceAddStmt = conn.prepareCall("{call p_add_device_event_condition(?,?,?,?,?,?,?)}");
            DeviceAddStmt.setInt(1, tUserDeviceId);
            DeviceAddStmt.setString(2, eEventName);
            DeviceAddStmt.setString(3, eEventCriteria);
            if (eMaxFieldValue != null) {
                DeviceAddStmt.setDouble(4, eMaxFieldValue);
            } else {
                DeviceAddStmt.setNull(4, Types.DECIMAL);
            }
            if (eMinFieldValue != null) {
                DeviceAddStmt.setDouble(5, eMinFieldValue);
            } else {
                DeviceAddStmt.setNull(5, Types.DECIMAL);
            }
            DeviceAddStmt.setInt(6, eRelationDeviceId);
            DeviceAddStmt.setInt(7, eRelationDeviceMethodId);

            DeviceAddStmt.execute();

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();

        }

    }


}
