package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.server.Sizeable;
import com.vaadin.shared.ui.MarginInfo;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 19.01.2017.
 */
public class tDetectorLayout extends VerticalLayout {

    Button tReturnParentFolderButton;
    Integer tCurrentLeafId;
    Label TopLabel;
    tTreeContentLayout tParentContentLayout;
    Button EditSubTreeNameButton;
    Button DeleteSubTreeButton;
    int iUserDeviceId;
    tDetectorFormLayout DeviceDataLayout;
    tDetectorUnitsLayout DeviceUnitsLayout;
    tDescriptionLayout DeviceDescription;
    tPeriodMeasuresLayout DeviceMeasuresLayout;
    tDetectorLastMeasureLayout DeviceLastMeasure;

    public tDetectorLayout(int eUserDeviceId, String eLeafName, int eLeafId,tTreeContentLayout eParentContentLayout){

        this.tCurrentLeafId = eLeafId;
        this.tParentContentLayout = eParentContentLayout;
        iUserDeviceId = eUserDeviceId;

        TopLabel = new Label();
        TopLabel.setContentMode(ContentMode.HTML);


        TopLabel.setValue(FontAwesome.TACHOMETER.getHtml() + " " + eLeafName);
        TopLabel.addStyleName(ValoTheme.LABEL_COLORED);
        TopLabel.addStyleName(ValoTheme.LABEL_SMALL);
        TopLabel.addStyleName("TopLabel");

        DeviceDataLayout = new tDetectorFormLayout(iUserDeviceId);
        DeviceUnitsLayout = new tDetectorUnitsLayout(iUserDeviceId);


        tReturnParentFolderButton = new Button("Вверх");
        tReturnParentFolderButton.setIcon(FontAwesome.LEVEL_UP);
        tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_SMALL);
        tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        tReturnParentFolderButton.addStyleName("TopButton");

        tReturnParentFolderButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                Integer iParentLeafId = tParentContentLayout.GetParentLeafById(tCurrentLeafId);
                //System.out.println("tCurrentLeafId: " + tCurrentLeafId);
                //System.out.println("iParentLeafId: " + iParentLeafId);
                if (iParentLeafId != 0){
                    tParentContentLayout.tTreeContentLayoutRefresh(iParentLeafId,0);
                }
            }
        });

        EditSubTreeNameButton = new Button();
        EditSubTreeNameButton.setIcon(VaadinIcons.EDIT);
        EditSubTreeNameButton.addStyleName(ValoTheme.BUTTON_SMALL);
        EditSubTreeNameButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        EditSubTreeNameButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                    UI.getCurrent().addWindow(new tChangeNameWindow(tCurrentLeafId
                            ,tParentContentLayout
                            ,TopLabel
                            ,DeviceDataLayout.NameTextField
                    ));
            }
        });

        DeleteSubTreeButton = new Button("Удалить");
        DeleteSubTreeButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        DeleteSubTreeButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteSubTreeButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        DeleteSubTreeButton.addStyleName("TopButton");

        DeleteSubTreeButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                UI.getCurrent().addWindow(new tDeviceDeleteWindow(tCurrentLeafId
                        ,tParentContentLayout
                ));
            }
        });


        HorizontalLayout DetectorEditLayout = new HorizontalLayout(
                DeleteSubTreeButton
                ,tReturnParentFolderButton
        );
        DetectorEditLayout.setSizeUndefined();

        HorizontalLayout LabelEditLayout = new HorizontalLayout(
                TopLabel
                ,EditSubTreeNameButton
        );
        LabelEditLayout.setSizeUndefined();
        LabelEditLayout.setSpacing(true);

        HorizontalLayout TopLayout = new HorizontalLayout(
                LabelEditLayout
                ,DetectorEditLayout
        );

        TopLayout.setComponentAlignment(LabelEditLayout,Alignment.MIDDLE_LEFT);
        TopLayout.setComponentAlignment(DetectorEditLayout,Alignment.MIDDLE_RIGHT);

        TopLayout.setSizeFull();
        TopLayout.setMargin(new MarginInfo(false, true, false, true));

        DeviceMeasuresLayout = new tPeriodMeasuresLayout(iUserDeviceId);

        DeviceDescription = new tDescriptionLayout(iUserDeviceId);

        DeviceLastMeasure = new tDetectorLastMeasureLayout(iUserDeviceId);

        tUsefulFuctions.getUserDetectorData(
                iUserDeviceId
                ,DeviceDataLayout
                //,DeviceDescription
                ,DeviceUnitsLayout
        );

        VerticalLayout ContentLayout = new VerticalLayout(
                DeviceDataLayout
                ,DeviceUnitsLayout
                ,DeviceDescription
                ,DeviceLastMeasure
                ,DeviceMeasuresLayout
        );


        ContentLayout.setMargin(true);
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        VerticalSplitPanel SplPanel = new VerticalSplitPanel();
        SplPanel.setFirstComponent(TopLayout);
        SplPanel.setSecondComponent(ContentLayout);
        SplPanel.setSplitPosition(40, Unit.PIXELS);
        SplPanel.setMaxSplitPosition(40, Unit.PIXELS);
        SplPanel.setMinSplitPosition(40,Unit.PIXELS);

        SplPanel.setHeight("1200px");
        //SplPanel.setWidth("1000px");

        this.addComponent(SplPanel);
        this.setSpacing(true);
        this.setHeight("100%");
        this.setWidth("100%");


    }
}
