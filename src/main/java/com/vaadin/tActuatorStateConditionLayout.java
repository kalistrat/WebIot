package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.HierarchicalContainer;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 26.05.2017.
 */
public class tActuatorStateConditionLayout extends VerticalLayout {

    Button AddButton;
    Button DeleteButton;
    Button SaveButton;

    TreeTable StatesConditionTable;
    HierarchicalContainer StatesConditionContainer;
    int iUserDeviceId;
    tActuatorStatesLayout iActuatorStatesLayout;
    Integer iCurrentLeafId;

    class ConditionIds{
        Integer ConditionNum;
        Integer LeftSideItemId;
        Integer SignItemId;
        Integer RightSideItemId;
        Integer VarsItemId;
        Integer TimeItemId;
        Integer ActuatorStateId;

        ConditionIds(
                Integer actuatorStateId
                ,Integer conditionNum
                ,Integer leftSideItemId
                ,Integer signItemId
                ,Integer rightSideItemId
                ,Integer varsItemId
                ,Integer timeItemId
        ){
            ActuatorStateId = actuatorStateId;
            ConditionNum = conditionNum;
            LeftSideItemId = leftSideItemId;
            SignItemId = signItemId;
            RightSideItemId = rightSideItemId;
            VarsItemId = varsItemId;
            TimeItemId = timeItemId;
        }
    }

    public tActuatorStateConditionLayout(int eUserDeviceId
                ,tActuatorStatesLayout ActuatorStatesLayout
                ,Integer eCurrentLeafId
    ){

        iUserDeviceId = eUserDeviceId;
        iActuatorStatesLayout = ActuatorStatesLayout;
        iCurrentLeafId = eCurrentLeafId;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.TREE_TABLE.getHtml() + "  " + "Условия, реализующие состояния устройства");
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

                ConditionIds conditionIds = (ConditionIds) clickEvent.getButton().getData();

                tButtonTextFieldLayout leftSideLayout =
                        (tButtonTextFieldLayout) StatesConditionContainer
                                .getItem(conditionIds.LeftSideItemId)
                                .getItemProperty(2).getValue();
                tButtonTextFieldLayout rightSideLayout =
                        (tButtonTextFieldLayout) StatesConditionContainer
                                .getItem(conditionIds.RightSideItemId)
                                .getItemProperty(2).getValue();
                tSignConditionLayout SignLayout =
                        (tSignConditionLayout) StatesConditionContainer
                                .getItem(conditionIds.SignItemId)
                                .getItemProperty(2).getValue();
                tTimeConditionLayout TimeLayout =
                        (tTimeConditionLayout) StatesConditionContainer
                                .getItem(conditionIds.TimeItemId)
                                .getItemProperty(2).getValue();

                Integer iNewConditionNum = conditionIds.ConditionNum;
                Integer iAddActuatorStateId = conditionIds.ActuatorStateId;
                String LeftExpr = leftSideLayout.textfield.getValue();
                String RightExpr = rightSideLayout.textfield.getValue();
                String SignExpr = (String) SignLayout.SignValueSelect.getValue();
                String TimeInterval = TimeLayout.TimeIntervalTextField.getValue();

                System.out.println("iNewConditionNum : " + iNewConditionNum);
                System.out.println("iAddActuatorStateId : " + iAddActuatorStateId);
                System.out.println("LeftExpr : " + LeftExpr);
                System.out.println("RightExpr : " + RightExpr);
                System.out.println("SignExpr : " + SignExpr);
                System.out.println("TimeInterval : " + TimeInterval);


                AddButton.setEnabled(true);
                DeleteButton.setEnabled(true);
                SaveButton.setEnabled(false);


            }
        });

        AddButton = new Button();
        AddButton.setIcon(VaadinIcons.PLUS);
        AddButton.addStyleName(ValoTheme.BUTTON_SMALL);
        AddButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        AddButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

                int SelectedItemId = 0;
                for (int i=0; i<StatesConditionContainer.size();i++){
                    if (StatesConditionTable.isSelected(i+1)) {
                        SelectedItemId = i+1;
                    }
                }

                Integer SelectedItemParentId = (Integer) StatesConditionContainer.getParent(SelectedItemId);

                if (SelectedItemId == 0) {

                    Notification.show("Добавление невозможно",
                            "Вы не выбрали состояние,\n к которому нужно добавить условие",
                            Notification.Type.TRAY_NOTIFICATION);
                } else {

                    if (SelectedItemParentId != null) {

                        Notification.show("Добавление невозможно",
                                "Необходимо выбрать состояние,\n а не условие или его компонент",
                                Notification.Type.TRAY_NOTIFICATION);

                    } else {


                        int nit = StatesConditionContainer.size() + 1;

                        String SelectedItemName = (String) StatesConditionContainer.getItem(SelectedItemId).getItemProperty(1).getValue();

                        int NewConditionNum = getNewConditionNum(iUserDeviceId,SelectedItemName);
                        int iActuatorStateId = getActuatorStateId(iUserDeviceId,SelectedItemName);

                        StatesConditionTable.setChildrenAllowed(SelectedItemId, true);

                        Item SubHeaderItem = StatesConditionContainer.addItem(nit);
                        SubHeaderItem.getItemProperty(1).setValue("Условие № " + NewConditionNum);
                        SubHeaderItem.getItemProperty(2).setValue(null);
                        StatesConditionContainer.setParent(nit,SelectedItemId);

                        int LeftSideItemId = nit + 1;
                        Item LeftSideItem = StatesConditionContainer.addItem(nit + 1);

                        tButtonTextFieldLayout LeftSideFieldLayout = new tButtonTextFieldLayout("",true);
                        LeftSideItem.getItemProperty(1).setValue("Левая часть выражения");
                        LeftSideItem.getItemProperty(2).setValue(LeftSideFieldLayout);
                        StatesConditionContainer.setParent(nit + 1, nit);

                        int SignItemItemId = nit + 2;
                        Item SignItem = StatesConditionContainer.addItem(nit + 2);

                        tSignConditionLayout SignLayout = new tSignConditionLayout(">",true);
                        SignItem.getItemProperty(1).setValue("Знак выражения");
                        SignItem.getItemProperty(2).setValue(SignLayout);
                        StatesConditionContainer.setParent(nit + 2, nit);

                        int RightSideItemId = nit + 3;
                        Item RightSideItem = StatesConditionContainer.addItem(nit + 3);
                        tButtonTextFieldLayout RightSideFieldLayout = new tButtonTextFieldLayout("",true);
                        RightSideItem.getItemProperty(1).setValue("Правая часть выражения");
                        RightSideItem.getItemProperty(2).setValue(RightSideFieldLayout);
                        StatesConditionContainer.setParent(nit + 3, nit);

                        int VarsItemId = nit + 4;
                        Item VarsItem = StatesConditionContainer.addItem(nit + 4);
                        VarsItem.getItemProperty(1).setValue("Соответствие переменных");
                        VarsItem.getItemProperty(2).setValue(
                                new tVarConditionLayout(
                                        0
                                        , LeftSideFieldLayout.textfield
                                        , RightSideFieldLayout.textfield
                                        , iActuatorStatesLayout
                                        , true
                                )
                        );

                        StatesConditionContainer.setParent(nit + 4, nit);

                        int TimeItemId = nit + 5;

                        Item TimeItem = StatesConditionContainer.addItem(nit + 5);
                        tTimeConditionLayout TimeLayout = new tTimeConditionLayout("",true);
                        TimeItem.getItemProperty(1).setValue("Интервал реализации условия");
                        TimeItem.getItemProperty(2).setValue(TimeLayout);

                        StatesConditionContainer.setParent(nit + 5, nit);

                        SaveButton.setData(new ConditionIds(
                                iActuatorStateId
                                ,NewConditionNum
                                ,LeftSideItemId
                                ,SignItemItemId
                                ,RightSideItemId
                                ,VarsItemId
                                ,TimeItemId
                        ));

                        for (Object itemId: StatesConditionTable.getContainerDataSource()
                                .getItemIds()) {
                            StatesConditionTable.setCollapsed(itemId, false);

                            // Also disallow expanding leaves
                            if (! StatesConditionTable.hasChildren(itemId))
                                StatesConditionTable.setChildrenAllowed(itemId, false);
                        }

                        StatesConditionTable.setPageLength(StatesConditionContainer.size());

                        AddButton.setEnabled(false);
                        DeleteButton.setEnabled(false);
                        SaveButton.setEnabled(true);
                    }

                }

            }
        });

        DeleteButton = new Button();
        DeleteButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        DeleteButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

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

        StatesConditionTable = new TreeTable();
        StatesConditionTable.setWidth("100%");

        StatesConditionTable.setColumnHeader(1, "Наименование<br/>состояния");
        StatesConditionTable.setColumnHeader(2, "Компоненты условия");

        StatesConditionContainer = new HierarchicalContainer();

        StatesConditionContainer.addContainerProperty(1, String.class, null);
        StatesConditionContainer.addContainerProperty(2, VerticalLayout.class, null);

        StatesConditionTable.setColumnWidth(1,-1);
        StatesConditionTable.setColumnWidth(2,-1);

        ActuatorStatesLayout.setListener(new addDeleteListener() {
            @Override
            public void afterDelete(String itemName) {

                StateConditionTableRefresh();
                DeleteButton.setEnabled(true);
                AddButton.setEnabled(true);
                SaveButton.setEnabled(false);

            }

            @Override
            public void afterAdd(String itemName) {

                StateConditionTableRefresh();
                DeleteButton.setEnabled(true);
                AddButton.setEnabled(true);
                SaveButton.setEnabled(false);
            }
        });

        setStatesConditionContainer();

        StatesConditionTable.setContainerDataSource(StatesConditionContainer);

        // Expand the tree
        for (Object itemId: StatesConditionTable.getContainerDataSource()
                .getItemIds()) {
            StatesConditionTable.setCollapsed(itemId, false);
            // Also disallow expanding leaves
            if (! StatesConditionTable.hasChildren(itemId))
                StatesConditionTable.setChildrenAllowed(itemId, false);

        }

        StatesConditionTable.setPageLength(StatesConditionContainer.size());

//        if (StatesConditionContainer.size()<6) {
//            StatesConditionTable.setPageLength(StatesConditionContainer.size());
//        } else {
//            StatesConditionTable.setPageLength(6);
//        }

        StatesConditionTable.addStyleName(ValoTheme.TREETABLE_SMALL);
        StatesConditionTable.addStyleName(ValoTheme.TREETABLE_COMPACT);
        StatesConditionTable.addStyleName("TableRow");


        StatesConditionTable.setSelectable(true);


        VerticalLayout TableLayout = new VerticalLayout(
                StatesConditionTable
        );
        TableLayout.setWidth("100%");
        TableLayout.setHeightUndefined();
        TableLayout.setComponentAlignment(StatesConditionTable,Alignment.MIDDLE_CENTER);
        //StatesTableLayout.addStyleName(ValoTheme.LAYOUT_WELL);

        VerticalLayout ContentLayout = new VerticalLayout(
                HeaderLayout
                ,TableLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);

    }

    public void setStatesConditionContainer(){

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select uas.actuator_state_name\n" +
                    ",ifnull(stc.actuator_state_condition_id,0)\n" +
                    ",stc.left_part_expression\n" +
                    ",stc.sign_expression\n" +
                    ",stc.right_part_expression\n" +
                    ",stc.condition_num\n" +
                    ",stc.condition_interval\n" +
                    "from user_actuator_state uas\n" +
                    "left join user_actuator_state_condition stc \n" +
                    "on stc.user_actuator_state_id=uas.user_actuator_state_id\n" +
                    "where uas.user_device_id = ?\n" +
                    "order by uas.user_actuator_state_id,stc.condition_num";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
            DataStmt.setInt(1,iUserDeviceId);

            ResultSet DataRs = DataStmt.executeQuery();

            int k = 0;

            while (DataRs.next()) {

                if (DataRs.getInt(2)!= 0) {

                    k = k + 7;

                    Item HeaderItem = StatesConditionContainer.addItem(k - 6);
                    HeaderItem.getItemProperty(1).setValue(DataRs.getString(1));
                    HeaderItem.getItemProperty(2).setValue(null);

                    Item SubHeaderItem = StatesConditionContainer.addItem(k - 5);
                    SubHeaderItem.getItemProperty(1).setValue("Условие № " + DataRs.getString(6));
                    SubHeaderItem.getItemProperty(2).setValue(null);
                    StatesConditionContainer.setParent(k - 5, k - 6);

                    Item LeftSideItem = StatesConditionContainer.addItem(k - 4);
                    tButtonTextFieldLayout LeftSideFieldLayout = new tButtonTextFieldLayout(DataRs.getString(3),false);
                    LeftSideItem.getItemProperty(1).setValue("Левая часть выражения");
                    LeftSideItem.getItemProperty(2).setValue(LeftSideFieldLayout);
                    StatesConditionContainer.setParent(k - 4, k - 5);

                    Item SignItem = StatesConditionContainer.addItem(k - 3);
                    SignItem.getItemProperty(1).setValue("Знак выражения");
                    SignItem.getItemProperty(2).setValue(new tSignConditionLayout(DataRs.getString(4),false));
                    StatesConditionContainer.setParent(k - 3, k - 5);

                    Item RightSideItem = StatesConditionContainer.addItem(k - 2);
                    tButtonTextFieldLayout RightSideFieldLayout = new tButtonTextFieldLayout(DataRs.getString(5),false);
                    RightSideItem.getItemProperty(1).setValue("Правая часть выражения");
                    RightSideItem.getItemProperty(2).setValue(RightSideFieldLayout);
                    StatesConditionContainer.setParent(k - 2, k - 5);

                    Item VarsItem = StatesConditionContainer.addItem(k - 1);
                    VarsItem.getItemProperty(1).setValue("Соответствие переменных");
                    VarsItem.getItemProperty(2).setValue(
                            new tVarConditionLayout(
                                    DataRs.getInt(2)
                                    , LeftSideFieldLayout.textfield
                                    , RightSideFieldLayout.textfield
                                    , iActuatorStatesLayout
                                    , false
                            )
                    );
                    StatesConditionContainer.setParent(k - 1, k - 5);

                    Item TimeItem = StatesConditionContainer.addItem(k);
                    TimeItem.getItemProperty(1).setValue("Интервал реализации условия");
                    TimeItem.getItemProperty(2).setValue(new tTimeConditionLayout(
                            String.valueOf(DataRs.getInt(7))
                            ,false)
                    );
                    StatesConditionContainer.setParent(k, k - 5);


                } else {
                    k = k + 1;
                    Item HeaderItem = StatesConditionContainer.addItem(k);
                    HeaderItem.getItemProperty(1).setValue(DataRs.getString(1));
                    HeaderItem.getItemProperty(2).setValue(null);

                }

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

    public void StateConditionTableRefresh(){
        StatesConditionContainer.removeAllItems();
        setStatesConditionContainer();
        // Expand the tree
        for (Object itemId: StatesConditionTable.getContainerDataSource()
                .getItemIds()) {
            StatesConditionTable.setCollapsed(itemId, false);

            if (! StatesConditionTable.hasChildren(itemId))
                StatesConditionTable.setChildrenAllowed(itemId, false);
        }

        StatesConditionTable.setPageLength(StatesConditionContainer.size());
    }

    public Integer getNewConditionNum(int qUserDeviceId,String qStateName){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement dataStmt = Con.prepareCall("{? = call f_get_next_condition_num(?, ?)}");
            dataStmt.registerOutParameter(1, Types.INTEGER);
            dataStmt.setInt(2, qUserDeviceId);
            dataStmt.setString(3, qStateName);
            dataStmt.execute();

            Integer iNewConditionNum = dataStmt.getInt(1);

            Con.close();

            return iNewConditionNum;

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
            return null;
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
            return null;
        }
    }

    public Integer getActuatorStateId(int qUserDeviceId,String qStateName){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement dataStmt = Con.prepareCall("{? = call f_get_actuator_state_id(?, ?)}");
            dataStmt.registerOutParameter(1, Types.INTEGER);
            dataStmt.setInt(2, qUserDeviceId);
            dataStmt.setString(3, qStateName);
            dataStmt.execute();

            Integer iActuatorStateId = dataStmt.getInt(1);

            Con.close();

            return iActuatorStateId;

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
            return null;
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
            return null;
        }
    }

}
