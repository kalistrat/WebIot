package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
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

    public tVarConditionLayout(int StateConditionId
            ,TextField leftExpressonTextFiled
            ,TextField rightExpressonTextFiled
    ){

        getVariableButton = new Button("Выбрать переменные");
        //getVariableButton.setIcon(FontAwesome.SAVE);
        getVariableButton.addStyleName(ValoTheme.BUTTON_TINY);
        getVariableButton.addStyleName(ValoTheme.BUTTON_LINK);
        getVariableButton.setHeight("20px");

        varListLayout = new VerticalLayout();

        this.addComponent(getVariableButton);
        this.setConditionVariables(StateConditionId);
        this.addComponent(varListLayout);
        this.setComponentAlignment(getVariableButton,Alignment.MIDDLE_CENTER);
        //this.setSpacing(true);
        this.setSizeUndefined();

    }

    public void setConditionVariables(int qStateConditionId){
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
                VarLabel.setValue(DataRs.getString(2)+ " " + VaadinIcons.ARROW_RIGHT.getHtml() + " ");
                VarLabel.addStyleName(ValoTheme.LABEL_COLORED);
                VarLabel.addStyleName(ValoTheme.LABEL_SMALL);

                NativeSelect VarSelect = new NativeSelect();
                VarSelect.setNullSelectionAllowed(false);
                VarSelect.setEnabled(false);
                VarSelect.select(DataRs.getString(2));

                HorizontalLayout VarLayout = new HorizontalLayout(
                        VarLabel
                        ,VarSelect
                );
                VarLayout.setSizeUndefined();
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
