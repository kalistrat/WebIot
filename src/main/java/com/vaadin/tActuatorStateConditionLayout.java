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

    class CondtionVar{
        String VarCode;
        Integer VarUserDeviceId;
        CondtionVar(String varCode,Integer varUserDeviceId){
            VarCode = varCode;
            VarUserDeviceId = varUserDeviceId;
        }
    }

    public tActuatorStateConditionLayout(int eUserDeviceId
            ,tActuatorStatesLayout ActuatorStatesLayout
    ){

        iUserDeviceId = eUserDeviceId;

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

        AddButton = new Button();
        AddButton.setIcon(VaadinIcons.PLUS);
        AddButton.addStyleName(ValoTheme.BUTTON_SMALL);
        AddButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

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

        StatesConditionTable.setColumnHeader(1, "Наименование<br/>состояния");
        StatesConditionTable.setColumnHeader(2, "Компоненты условия");

        StatesConditionContainer = new HierarchicalContainer();
        StatesConditionContainer.addContainerProperty(1, String.class, null);
        StatesConditionContainer.addContainerProperty(2, VerticalLayout.class, null);

        ActuatorStatesLayout.setListener(new addDeleteListener() {
            @Override
            public void afterDelete(String itemName) {
                System.out.println("Удалён " + itemName + " вызываю обновление контейнера");
            }

            @Override
            public void afterAdd(String itemName) {
                System.out.println("Добавлен " + itemName + " вызываю обновление контейнера");
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
                    ",stc.actuator_state_condition_id\n" +
                    ",stc.left_part_expression\n" +
                    ",stc.sign_expression\n" +
                    ",stc.right_part_expression\n" +
                    ",ifnull(stc.condition_num,@num:=@num+1) condition_num\n" +
                    ",stc.condition_interval\n" +
                    "from user_actuator_state uas\n" +
                    "join (select @num:=0) t\n" +
                    "left join user_actuator_state_condition stc \n" +
                    "on stc.user_actuator_state_id=uas.user_actuator_state_id\n" +
                    "where uas.user_device_id = ?\n" +
                    "order by uas.user_actuator_state_id,stc.condition_num";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
            DataStmt.setInt(1,iUserDeviceId);

            ResultSet DataRs = DataStmt.executeQuery();

            int k = 1;

            while (DataRs.next()) {

                Item HeaderItem = StatesConditionContainer.addItem(k);
                HeaderItem.getItemProperty(1).setValue(DataRs.getString(1));
                HeaderItem.getItemProperty(2).setValue(null);

                Item SubHeaderItem = StatesConditionContainer.addItem(k+1);
                SubHeaderItem.getItemProperty(1).setValue("Условие № " + DataRs.getString(6));
                SubHeaderItem.getItemProperty(2).setValue(null);
                StatesConditionContainer.setParent(k+1,k);

                Item LeftSideItem = StatesConditionContainer.addItem(k+2);
                String leftExpr;
                if (DataRs.getString(3) != null) {
                    leftExpr = DataRs.getString(3);
                } else {
                    leftExpr = "";
                }

                tButtonTextFieldLayout LeftSideFieldLayout = new tButtonTextFieldLayout(leftExpr);
                LeftSideItem.getItemProperty(1).setValue("Левая часть выражения");
                LeftSideItem.getItemProperty(2).setValue(LeftSideFieldLayout);
                StatesConditionContainer.setParent(k+2,k+1);

                Item SignItem = StatesConditionContainer.addItem(k+3);
                SignItem.getItemProperty(1).setValue("Знак выражения");
                NativeSelect SignValueSelect = new NativeSelect();
                SignValueSelect.addItem(">");
                SignValueSelect.addItem("<");
                SignValueSelect.addItem("=");
                SignValueSelect.addItem(">=");
                SignValueSelect.addItem("<=");
                SignValueSelect.addStyleName("SelectFont");
                SignValueSelect.setNullSelectionAllowed(false);
                if (DataRs.getString(4) != null) {
                    SignValueSelect.select(DataRs.getString(4));
                } else {
                    SignValueSelect.select(">");
                }
                VerticalLayout SignLayout = new VerticalLayout(SignValueSelect);
                SignLayout.setSizeUndefined();
                SignLayout.setMargin(false);
                SignItem.getItemProperty(2).setValue(SignLayout);
                StatesConditionContainer.setParent(k+3,k+1);

                Item RightSideItem = StatesConditionContainer.addItem(k+4);
                String rightExpr;
                if (DataRs.getString(5) != null) {
                    rightExpr = DataRs.getString(5);
                } else {
                    rightExpr = "";
                }
                tButtonTextFieldLayout RightSideFieldLayout = new tButtonTextFieldLayout(rightExpr);
                RightSideItem.getItemProperty(1).setValue("Правая часть выражения");
                RightSideItem.getItemProperty(2).setValue(RightSideFieldLayout);
                StatesConditionContainer.setParent(k+4,k+1);

                Item VarsItem = StatesConditionContainer.addItem(k+5);
                VarsItem.getItemProperty(1).setValue("Соответствие переменных");

                VarsItem.getItemProperty(2).setValue(
                        new tVarConditionLayout(
                                DataRs.getInt(2)
                                ,LeftSideFieldLayout.textfield
                                ,RightSideFieldLayout.textfield
                                )
                );

                StatesConditionContainer.setParent(k+5,k+1);

                Item TimeItem = StatesConditionContainer.addItem(k+6);
                TextField TimeIntervelTextField = new TextField();
                TimeIntervelTextField.addStyleName(ValoTheme.TEXTFIELD_TINY);
                TimeIntervelTextField.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
                TimeIntervelTextField.setNullRepresentation("");
                TimeIntervelTextField.setInputPrompt("Задайте интервал в секундах");

                if (DataRs.getInt(7)==0) {
                    TimeIntervelTextField.setValue(null);
                } else {
                    TimeIntervelTextField.setValue(String.valueOf(DataRs.getInt(7)));
                }

                VerticalLayout TimeLayout = new VerticalLayout(TimeIntervelTextField);
                TimeLayout.setMargin(false);
                TimeItem.getItemProperty(1).setValue("Интервал реализации условия");
                TimeItem.getItemProperty(2).setValue(TimeLayout);

                StatesConditionContainer.setParent(k+6,k+1);

                k = k + 7;

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
}
