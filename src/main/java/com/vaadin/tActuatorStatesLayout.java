package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.event.ItemClickEvent;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;

/**
 * Created by kalistrat on 26.05.2017.
 */
public class tActuatorStatesLayout extends VerticalLayout {
    Button AddButton;
    Button DeleteButton;
    Button SaveButton;

    Table StatesTable;
    IndexedContainer StatesContainer;
    int iUserDeviceId;


    public tActuatorStatesLayout(int eUserDeviceId){

        iUserDeviceId = eUserDeviceId;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.TABLE.getHtml() + "  " + "Перечень возможных состояний устройства");
        Header.addStyleName(ValoTheme.LABEL_COLORED);
        Header.addStyleName(ValoTheme.LABEL_SMALL);

        SaveButton = new Button();
        SaveButton.setIcon(FontAwesome.SAVE);
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        SaveButton.setEnabled(false);

        SaveButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                Item ThatItem = (Item) clickEvent.getButton().getData();

                String InputName = ((TextField) ThatItem.getItemProperty(2).getValue()).getValue();
                String InputCode = ((TextField) ThatItem.getItemProperty(3).getValue()).getValue();

                //System.out.println("InputName :" + InputName);
                //System.out.println("InputCode :" + InputCode);

                String sErrorMessage = "";

                if (InputName == null){
                    sErrorMessage = "Наименование состояния не задано\n";
                }

                if (InputName.equals("")){
                    sErrorMessage = sErrorMessage + "Наименование состояния не задано\n";
                }

                if (InputName.length() > 25){
                    sErrorMessage = sErrorMessage + "Длина наименования превышает 25 символов\n";
                }

                if (isStatesContainerContainsName(InputName)){
                    sErrorMessage = sErrorMessage + "Указанное наименование уже используется. Введите другое.\n";
                }

                if (InputCode == null){
                    sErrorMessage = sErrorMessage + "Код сообщения не задан\n";
                }

                if (InputCode.equals("")){
                    sErrorMessage = sErrorMessage + "Код сообщения не задан\n";
                }

                if (InputCode.length() > 20){
                    sErrorMessage = sErrorMessage + "Длина кода сообщения превышает 20 символов\n";
                }

                if (isStatesContainerContainsCode(InputCode)){
                    sErrorMessage = sErrorMessage + "Указанный код уже используется. Введите другой.\n";
                }

                if (!tUsefulFuctions.IsLatinAndDigits(InputCode)){
                    sErrorMessage = sErrorMessage + "Указанный код недопустим. Он должен состоять из букв латиницы и цифр\n";
                }

                if (!sErrorMessage.equals("")){
                    Notification.show("Ошибка сохранения:",
                            sErrorMessage,
                            Notification.Type.TRAY_NOTIFICATION);
                } else {
                    ((TextField) ThatItem.getItemProperty(2).getValue()).setEnabled(false);
                    ((TextField) ThatItem.getItemProperty(3).getValue()).setEnabled(false);
                    newActuatorStateInsert(iUserDeviceId,InputName,InputCode);
                    DeleteButton.setEnabled(true);
                    AddButton.setEnabled(true);
                    SaveButton.setEnabled(false);
                }

            }
        });

        AddButton = new Button();
        AddButton.setIcon(VaadinIcons.PLUS);
        AddButton.addStyleName(ValoTheme.BUTTON_SMALL);
        AddButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        AddButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                DeleteButton.setEnabled(false);
                AddButton.setEnabled(false);

                int NewItemNum = StatesContainer.size()+1;

                Item AddedItem = StatesContainer.addItem(NewItemNum);
                AddedItem.getItemProperty(1).setValue(NewItemNum);

                TextField AddedNameTF = new TextField();
                AddedNameTF.setValue("");
                //AddedNameTF.setEnabled(false);
                AddedNameTF.addStyleName(ValoTheme.TEXTFIELD_TINY);
                AddedNameTF.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
                AddedItem.getItemProperty(2).setValue(AddedNameTF);

                TextField AddedCodeTF = new TextField();
                AddedCodeTF.setValue("");
                //AddedCodeTF.setEnabled(false);
                AddedCodeTF.addStyleName(ValoTheme.TEXTFIELD_TINY);
                AddedCodeTF.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
                AddedItem.getItemProperty(3).setValue(AddedCodeTF);

                SaveButton.setData(AddedItem);
                SaveButton.setEnabled(true);
                DeleteButton.setEnabled(false);

            }
        });

        DeleteButton = new Button();
        DeleteButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        DeleteButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        DeleteButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                int SelectedItemId = 0;
                for (int i=0; i<StatesContainer.size();i++){
                    if (StatesTable.isSelected(i+1)) {
                        SelectedItemId = i+1;
                    }
                }

                if (SelectedItemId>0) {
                    String ItemCode = (String) ((TextField) StatesContainer
                            .getItem(SelectedItemId)
                            .getItemProperty(3)
                            .getValue()).getValue();

                    ActuatorStateDelete(iUserDeviceId,ItemCode);
                    StatesContainerRefresh();

                    Notification.show("Удаление произведено",
                            null,
                            Notification.Type.TRAY_NOTIFICATION);
                } else {
                    Notification.show("Удаление невозможно:",
                            "Не выбрано ни одной строки",
                            Notification.Type.TRAY_NOTIFICATION);
                }



            }
        });


        HorizontalLayout HeaderButtons = new HorizontalLayout(
                DeleteButton
                ,AddButton
                ,SaveButton
        );
        HeaderButtons.setSpacing(true);
        HeaderButtons.setSizeUndefined();

        HorizontalLayout HeaderLayout = new HorizontalLayout(
                Header
                ,HeaderButtons
        );
        HeaderLayout.setWidth("100%");
        HeaderLayout.setHeightUndefined();
        HeaderLayout.setComponentAlignment(Header, Alignment.MIDDLE_LEFT);
        HeaderLayout.setComponentAlignment(HeaderButtons,Alignment.MIDDLE_RIGHT);

        StatesTable = new Table();

        StatesTable.setColumnHeader(1, "№<br/>состояния");
        StatesTable.setColumnHeader(2, "Наименование<br/>состояния");
        StatesTable.setColumnHeader(3, "Код<br/>сообщения");

        StatesContainer = new IndexedContainer();
        StatesContainer.addContainerProperty(1, Integer.class, null);
        StatesContainer.addContainerProperty(2, TextField.class, null);
        StatesContainer.addContainerProperty(3, TextField.class, null);

        setStatesContainer();
        StatesTable.setContainerDataSource(StatesContainer);
        if (StatesContainer.size()<6) {
            StatesTable.setPageLength(StatesContainer.size());
        } else {
            StatesTable.setPageLength(6);
        }
        StatesTable.addStyleName(ValoTheme.TABLE_COMPACT);
        StatesTable.addStyleName(ValoTheme.TABLE_SMALL);
        StatesTable.addStyleName("TableRow");

//        StatesTable.setCellStyleGenerator(new Table.CellStyleGenerator() {
//            @Override
//            public String getStyle(Table components, Object itemId, Object columnId) {
//                return "mytabletext";
//            }
//        });
        StatesTable.setSelectable(true);


//        StatesTable.addItemClickListener(new ItemClickEvent.ItemClickListener() {
//            @Override
//            public void itemClick(ItemClickEvent itemClickEvent) {
//
//                //String SelectedItemName = ((TextField) itemClickEvent.getItem().getItemProperty(2).getValue()).getValue();
//                //System.out.println("SelectedItemName :" + SelectedItemName);
//
//                SelectedItemId = (Integer) itemClickEvent.getItem().getItemProperty(1).getValue();
//                //System.out.println("SelectedItemId :" + SelectedItemId);
//
//            }
//        });

        VerticalLayout StatesTableLayout = new VerticalLayout(
                StatesTable
        );
        StatesTableLayout.setWidth("100%");
        StatesTableLayout.setHeightUndefined();
        StatesTableLayout.setComponentAlignment(StatesTable,Alignment.MIDDLE_CENTER);
        //StatesTableLayout.addStyleName(ValoTheme.LAYOUT_WELL);

        VerticalLayout ContentLayout = new VerticalLayout(
                HeaderLayout
                ,StatesTableLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);

    }

    public void setStatesContainer(){

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select @num1:=@num1+1 num\n" +
                    ",uas.actuator_state_name\n" +
                    ",uas.actuator_message_code\n" +
                    "from user_actuator_state uas\n" +
                    "join (select @num1:=0) t1\n" +
                    "where uas.user_device_id = ?";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
            DataStmt.setInt(1,iUserDeviceId);

            ResultSet DataRs = DataStmt.executeQuery();

            while (DataRs.next()) {

                Item newItem = StatesContainer.addItem(DataRs.getInt(1));

                TextField NameTF = new TextField();
                NameTF.setValue(DataRs.getString(2));
                NameTF.setEnabled(false);
                NameTF.addStyleName(ValoTheme.TEXTFIELD_TINY);
                NameTF.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);

                TextField CodeTF = new TextField();
                CodeTF.setValue(DataRs.getString(3));
                CodeTF.setEnabled(false);
                CodeTF.addStyleName(ValoTheme.TEXTFIELD_TINY);
                CodeTF.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);

                newItem.getItemProperty(1).setValue(DataRs.getInt(1));
                newItem.getItemProperty(2).setValue(NameTF);
                newItem.getItemProperty(3).setValue(CodeTF);

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

    public void StatesContainerRefresh(){
        StatesContainer.removeAllItems();
        setStatesContainer();
        if (StatesContainer.size()<6) {
            StatesTable.setPageLength(StatesContainer.size());
        } else {
            StatesTable.setPageLength(6);
        }
    }

    public boolean isStatesContainerContainsName(String NewItemName){
        int k = 0;

        for (int i=0; i<StatesContainer.size()-1; i++){
            String ItemName = (String) ((TextField) StatesContainer.getItem(i+1).getItemProperty(2).getValue()).getValue();
            if (ItemName.equals(NewItemName)){
                k = k + 1;
            }
        }

        if (k>0) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isStatesContainerContainsCode(String NewCode){
        int k = 0;

        for (int i=0; i<StatesContainer.size()-1; i++){
            String ItemCode = (String) ((TextField) StatesContainer.getItem(i+1).getItemProperty(3).getValue()).getValue();
            if (ItemCode.equals(NewCode)){
                k = k + 1;
            }
        }

        if (k>0) {
            return true;
        } else {
            return false;
        }
    }

    public void newActuatorStateInsert(
            int qUserDeviceId
            ,String qStateName
            ,String qStateCode
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement Stmt = Con.prepareCall("{call p_insert_actuator_state(?, ?, ?)}");
            Stmt.setInt(1, qUserDeviceId);
            Stmt.setString(2, qStateName);
            Stmt.setString(3, qStateCode);

            Stmt.execute();

            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

    }

    public void ActuatorStateDelete(
            int qUserDeviceId
            ,String qStateCode
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement Stmt = Con.prepareCall("{call p_delete_actuator_state(?, ?)}");
            Stmt.setInt(1, qUserDeviceId);
            Stmt.setString(2, qStateCode);

            Stmt.execute();

            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

    }
}
