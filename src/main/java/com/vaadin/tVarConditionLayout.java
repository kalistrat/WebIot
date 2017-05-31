package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.MarginInfo;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.util.List;

/**
 * Created by kalistrat on 29.05.2017.
 */
public class tVarConditionLayout extends VerticalLayout {

    //List<String> VarList;
    Button getVariableButton;
    VerticalLayout varListLayout;
    tActuatorStatesLayout iActuatorStatesLayout;


    public tVarConditionLayout(int StateConditionId
                ,TextField leftExpressonTextFiled
                ,TextField rightExpressonTextFiled
                ,tActuatorStatesLayout actuatorStatesLayout
                ,boolean isSelectEnable
    ){
        iActuatorStatesLayout = actuatorStatesLayout;

        getVariableButton = new Button("Выбрать переменные");
        //getVariableButton.setIcon(FontAwesome.SAVE);
        getVariableButton.addStyleName(ValoTheme.BUTTON_TINY);
        getVariableButton.addStyleName(ValoTheme.BUTTON_LINK);
        getVariableButton.setHeight("20px");

        getVariableButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

                varListLayout.removeAllComponents();
                MathParser leftParser = new MathParser();
                String leftSideExpr = leftExpressonTextFiled.getValue();
                String rightSideExpr = rightExpressonTextFiled.getValue();
                int k = 0;
                while (k < 150) {

                    try {
                        double leftSideValue = leftParser.Parse(leftSideExpr);
                        k = 150;
                        System.out.println("leftSideValue :" + leftSideValue);
                    } catch (Exception e) {
                        String MessAge = e.getMessage();
                        System.out.println("MessAge : " + MessAge);
                        if (MessAge.contains("нет переменной")) {
                            List<String> MessPieces = tUsefulFuctions.GetListFromString(MessAge, "|");
                            System.out.println("MessPieces :" + MessPieces.get(0));
                            leftParser.setVariable(MessPieces.get(1), 7.0);
                            k = k + 1;
                        } else {
                            varListLayout.addComponent(new Label(MessAge));
                            addComponent(varListLayout);
                            k = 150;
                        }
                    }
                    System.out.println("k : " + k);
                }

                for (String iL : leftParser.VarList) {
                    System.out.println(iL);
                }
                leftParser.VarList.clear();
                leftParser.var.clear();

            }
        });

        varListLayout = new VerticalLayout();
        varListLayout.setSpacing(true);

        this.addComponent(getVariableButton);
        if (StateConditionId != 0) {
            getVariableButton.setEnabled(false);
            this.setConditionVariables(StateConditionId,isSelectEnable);
            this.addComponent(varListLayout);
        }
        this.setComponentAlignment(getVariableButton,Alignment.MIDDLE_CENTER);
        this.setSpacing(true);
        this.setMargin(new MarginInfo(false,true,false,true));
        this.setSizeUndefined();

    }

    public void setConditionVariables(int qStateConditionId, boolean qSelectEnable){
        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select condv.var_code\n" +
                    ",ud.device_user_name\n" +
                    "from user_state_condition_vars condv\n" +
                    "join user_device ud on ud.user_device_id=condv.user_device_id\n" +
                    "where condv.actuator_state_condition_id = ?\n" +
                    "order by state_condition_vars_id";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
            DataStmt.setInt(1,qStateConditionId);

            ResultSet DataRs = DataStmt.executeQuery();

            while (DataRs.next()) {

                Label VarLabel = new Label();
                VarLabel.setContentMode(ContentMode.HTML);
                VarLabel.setValue(DataRs.getString(1)+ " " + VaadinIcons.ARROW_RIGHT.getHtml());
                VarLabel.addStyleName(ValoTheme.LABEL_COLORED);
                VarLabel.addStyleName(ValoTheme.LABEL_SMALL);
                VarLabel.addStyleName("TopLabel");

                tChildDetectorSelect VarSelect = new tChildDetectorSelect(iActuatorStatesLayout);
                VarSelect.setNullSelectionAllowed(false);
                VarSelect.setEnabled(qSelectEnable);
                VarSelect.select(DataRs.getString(2));

                HorizontalLayout VarLayout = new HorizontalLayout(
                        VarLabel
                        ,VarSelect
                );
                VarLayout.setSizeUndefined();
                VarLayout.setSpacing(true);
                varListLayout.addComponent(VarLayout);

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
