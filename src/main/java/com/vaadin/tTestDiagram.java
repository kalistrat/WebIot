package com.vaadin;

import com.google.gson.Gson;
import com.vaadin.data.Item;
import com.vaadin.data.validator.IntegerRangeValidator;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 13.11.2017.
 */
public class tTestDiagram extends VerticalLayout {

    Button RefreshButton;
    int iUserDeviceId;
    Diagram diagram;
    String jSonData;

    public tTestDiagram(){

        iUserDeviceId = 12;
        String actionType = "DETECTOR";
        String headerTxt;
        String lastMeasureValName;
        String lastMeasureDateName;

        if (actionType.equals("ACTUATOR")) {
            headerTxt = "Последнее состояние устройства";
            lastMeasureValName = "Код состояния :";
            lastMeasureDateName = "Дата состояния :";
        } else {
            headerTxt = "Последнее измерение устройства";
            lastMeasureValName = "Величина измерения :";
            lastMeasureDateName = "Дата измерения :";
        }

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.SPARK_LINE.getHtml() + "  " + headerTxt);
        Header.addStyleName(ValoTheme.LABEL_COLORED);
        Header.addStyleName(ValoTheme.LABEL_SMALL);

        RefreshButton = new Button();
        RefreshButton.setIcon(VaadinIcons.REFRESH);
        RefreshButton.addStyleName(ValoTheme.BUTTON_SMALL);
        RefreshButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        RefreshButton.setEnabled(true);

        RefreshButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

            }
        });


        HorizontalLayout FormHeaderButtons = new HorizontalLayout(
                RefreshButton
        );
        FormHeaderButtons.setSpacing(true);
        FormHeaderButtons.setSizeUndefined();

        HorizontalLayout FormHeaderLayout = new HorizontalLayout(
                Header
                , FormHeaderButtons
        );
        FormHeaderLayout.setWidth("100%");
        FormHeaderLayout.setHeightUndefined();
        FormHeaderLayout.setComponentAlignment(Header, Alignment.MIDDLE_LEFT);
        FormHeaderLayout.setComponentAlignment(FormHeaderButtons, Alignment.MIDDLE_RIGHT);


        diagram = new Diagram();
        List<tDetectorDiagramData> dList = new ArrayList<>();
        dList.add(new tDetectorDiagramData("01.01.2000 12:01:33",1394.46));
        dList.add(new tDetectorDiagramData("01.02.2000 23:14:33",1366.42));
        dList.add(new tDetectorDiagramData("01.03.2000 03:30:63",1498.58));
        dList.add(new tDetectorDiagramData("01.04.2000 10:01:33",1452.43));
        dList.add(new tDetectorDiagramData("01.05.2000 08:30:53",1420.6));
        dList.add(new tDetectorDiagramData("01.06.2000 15:22:13",1454.6));
        dList.add(new tDetectorDiagramData("01.06.2001 15:22:13",454.6));

        diagram.setCoords((new Gson()).toJson(dList));

        //System.out.println("diagram.getState().getGraphData() : " + diagram.getState().getCoords());

        diagram.addStyleName("diagram");

        VerticalLayout ContentLayout = new VerticalLayout(
                FormHeaderLayout
                ,diagram
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);
    }

//    private void setDiagramData(){
//        try {
//            Class.forName(tUsefulFuctions.JDBC_DRIVER);
//            Connection Con = DriverManager.getConnection(
//                    tUsefulFuctions.DB_URL
//                    , tUsefulFuctions.USER
//                    , tUsefulFuctions.PASS
//            );
//
//            String DataSql = "";
//
//            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
//            DataStmt.setInt(1,iUserDeviceId);
//
//            ResultSet DataRs = DataStmt.executeQuery();
//
//            while (DataRs.next()) {
//
//
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
//
//    }


}
