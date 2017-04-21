package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.Property;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

import java.sql.*;

/**
 * Created by kalistrat on 17.02.2017.
 */
public class tEventsControlDevicesLayout extends VerticalLayout {

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    Table EventsTable;
    Button AddEventButton;
    Button DeleteEventButton;
    IndexedContainer EventsContainer;
    int tUserDeviceId;
    Integer tSelectedRowId;

    public tEventsControlDevicesLayout(int eUserDeviceId){

        this.tUserDeviceId = eUserDeviceId;
        this.tSelectedRowId = null;


        AddEventButton = new Button("Добавить новое событие");
        AddEventButton.setIcon(VaadinIcons.PLUS_CIRCLE);
        AddEventButton.addStyleName(ValoTheme.BUTTON_SMALL);

        AddEventButton.setData(this);

        AddEventButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                tEventsControlDevicesLayout EVCLayout = (tEventsControlDevicesLayout) clickEvent.getButton().getData();
                UI.getCurrent().addWindow(new tAddEventDeviceWindow(tUserDeviceId,EVCLayout));
            }
        });


        DeleteEventButton = new Button("Удалить выбранное событие");
        DeleteEventButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        DeleteEventButton.addStyleName(ValoTheme.BUTTON_SMALL);

        DeleteEventButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                if (tSelectedRowId!=null) {
                    DeleteEventDeviceCondition(tSelectedRowId);
                    refreshEventsContainer(tUserDeviceId);
                    Notification.show("Выбранное событие удалено",
                    null,
                    Notification.Type.TRAY_NOTIFICATION);
                } else {
                    Notification.show("Не выбрано ни одной строки",
                    null,
                    Notification.Type.TRAY_NOTIFICATION);
                }
            }
        });



        HorizontalLayout ButtonsLayout = new HorizontalLayout(
                AddEventButton
                ,DeleteEventButton
        );
        ButtonsLayout.setSpacing(true);

        EventsTable = new Table();
        //EventsTable.addStyleName(ValoTheme.TABLE_SMALL);

        EventsTable.setColumnHeader(1, "Наименование события");
        EventsTable.setColumnHeader(2, "Условие реализации события");
        EventsTable.setColumnHeader(3, "Вызываемое устройство");
        EventsTable.setColumnHeader(4, "Вызываемый метод");
        //EventsTable.setColumnWidth(2,-1);
        //EventsTable.setWidth("100%");
        EventsTable.setSelectable(true);

        EventsTable.addValueChangeListener(new Property.ValueChangeListener() {
            @Override
            public void valueChange(Property.ValueChangeEvent e) {
                //System.out.println("Выбранная строка" + e.getProperty().getValue());
                if (e.getProperty().getValue() != null) {
                    int SelectedItemId = (int) e.getProperty().getValue();
                    tIdLabel LabelVal = (tIdLabel) EventsContainer.getItem(SelectedItemId).getItemProperty(1).getValue();
                    tSelectedRowId = LabelVal.IdLabel;
                } else {
                    tSelectedRowId = null;
                }

//                Notification.show("Value changed:",
//                        String.valueOf(LabelVal.IdLabel),
//                        Notification.Type.TRAY_NOTIFICATION);



            }
        });

        EventsContainer = new IndexedContainer();

        EventsContainer.addContainerProperty(1, tIdLabel.class, null);
        EventsContainer.addContainerProperty(2, tCriteriaLabel.class, null);
        EventsContainer.addContainerProperty(3, String.class, null);
        EventsContainer.addContainerProperty(4, String.class, null);
        this.FillContainerData(this.tUserDeviceId);

        EventsTable.setContainerDataSource(this.EventsContainer);
        EventsTable.setPageLength(this.EventsContainer.size());


        this.setCaption("Настройка обработки событий связанными устройствами");
        this.setIcon(VaadinIcons.CONNECT);

        this.addComponent(ButtonsLayout);
        this.addComponent(EventsTable);
        this.setSpacing(true);
        //this.setSizeFull();
    }

    public void FillContainerData(int iUserDeviceId){

        try {
            Class.forName(JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(DB_URL, USER, PASS);

            String EventsSql = "select udec.user_device_event_condition_id\n" +
                    ",udec.user_device_event_name\n" +
                    ",ect.event_criteria_type_name\n" +
                    ",udec.event_max_val\n" +
                    ",udec.event_min_val\n" +
                    ",d.device_name\n" +
                    ",dm.method_name\n" +
                    "from user_device_event_condition udec\n" +
                    "join event_criteria_type ect on ect.event_criteria_type_id=udec.event_criteria_type_id\n" +
                    "join device_method dm on dm.device_method_id=udec.relation_user_device_method_id\n" +
                    "join user_device reud on reud.user_device_id=udec.relation_user_device_id\n" +
                    "join device d on d.device_id=reud.device_id\n" +
                    "where udec.user_device_id = ? \n" +
                    "order by udec.user_device_event_condition_id";

            PreparedStatement EventsSqlStmt = Con.prepareStatement(EventsSql);
            EventsSqlStmt.setInt(1, iUserDeviceId);
            ResultSet EventsSqlStmtRs = EventsSqlStmt.executeQuery();

            while (EventsSqlStmtRs.next()) {

                Item newItem = this.EventsContainer.getItem(this.EventsContainer.addItem());
                Integer iDeviceConditionId = EventsSqlStmtRs.getInt(1);
                String iEventName = EventsSqlStmtRs.getString(2);
                String iCriteriaName = EventsSqlStmtRs.getString(3);
                Double iMaxVal = EventsSqlStmtRs.getDouble(4);
                Double iMinVal = EventsSqlStmtRs.getDouble(5);
                String iRelationDeviceName = EventsSqlStmtRs.getString(6);
                String iRelationMethodName = EventsSqlStmtRs.getString(7);

                newItem.getItemProperty(1).setValue(new tIdLabel(iDeviceConditionId,iEventName));
                newItem.getItemProperty(2).setValue(new tCriteriaLabel(iCriteriaName,iMinVal,iMaxVal));
                newItem.getItemProperty(3).setValue(iRelationDeviceName);
                newItem.getItemProperty(4).setValue(iRelationMethodName);

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

    public void refreshEventsContainer(int iUserDeviceId){
        this.EventsContainer.removeAllItems();
        this.FillContainerData(iUserDeviceId);
        this.EventsTable.setPageLength(this.EventsContainer.size());
    }

    public void DeleteEventDeviceCondition(int iUserDeviceEventConditionId) {

        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement DeviceDeleteStmt = conn.prepareCall("{call p_delete_device_event_condition(?)}");
            DeviceDeleteStmt.setInt(1, iUserDeviceEventConditionId);
            DeviceDeleteStmt.execute();

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
