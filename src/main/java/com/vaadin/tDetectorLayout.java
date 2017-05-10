package com.vaadin;

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

    public tDetectorLayout(int eUserDeviceId, String eLeafName, int eLeafId,tTreeContentLayout eParentContentLayout){

        this.tCurrentLeafId = eLeafId;
        this.tParentContentLayout = eParentContentLayout;

        TopLabel = new Label();
        TopLabel.setContentMode(ContentMode.HTML);


        TopLabel.setValue(FontAwesome.TACHOMETER.getHtml() + " " + eLeafName);
        TopLabel.addStyleName(ValoTheme.LABEL_COLORED);
        TopLabel.addStyleName(ValoTheme.LABEL_SMALL);


        VerticalLayout DeviceDataLayout = new VerticalLayout(
                new Label(String.valueOf(eUserDeviceId))
        );

        tReturnParentFolderButton = new Button("Вверх");
        tReturnParentFolderButton.setIcon(FontAwesome.LEVEL_UP);
        tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_SMALL);
        //tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_ICON_ONLY);
        tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

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


        HorizontalLayout TopLabelLayout = new HorizontalLayout(TopLabel,tReturnParentFolderButton);
        TopLabelLayout.setComponentAlignment(TopLabel,Alignment.MIDDLE_LEFT);
        TopLabelLayout.setComponentAlignment(tReturnParentFolderButton,Alignment.MIDDLE_RIGHT);
        TopLabelLayout.setSizeFull();


        TopLabelLayout.setHeight("100%");
        DeviceDataLayout.setSizeUndefined();
        TopLabelLayout.setMargin(new MarginInfo(false, true, false, true));
        DeviceDataLayout.setMargin(true);
        DeviceDataLayout.setSpacing(true);

        VerticalSplitPanel SplPanel = new VerticalSplitPanel();
        SplPanel.setFirstComponent(TopLabelLayout);
        SplPanel.setSecondComponent(DeviceDataLayout);
        SplPanel.setSplitPosition(40, Sizeable.UNITS_PIXELS);
        SplPanel.setHeight("1200px");
        //SplPanel.setWidth("1000px");

        this.addComponent(SplPanel);
        this.setSpacing(true);
        this.setHeight("100%");
        this.setWidth("100%");


    }
}
