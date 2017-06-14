package com.vaadin;

import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

/**
 * Created by kalistrat on 14.12.2016.
 */
public class tRegistrationVeiw extends CustomComponent implements View {

    public static final String NAME = "Registration";
    Button ReturnLog;

    public tRegistrationVeiw(){
    }

    public void enter(ViewChangeListener.ViewChangeEvent event) {

        ReturnLog = new Button("Вернуться");
        ReturnLog.addStyleName(ValoTheme.BUTTON_LINK);
        ReturnLog.addStyleName(ValoTheme.BUTTON_SMALL);
        ReturnLog.setIcon(com.vaadin.icons.VaadinIcons.ENTER_ARROW);

        ReturnLog.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                getUI().getNavigator().navigateTo(tLoginView.NAME);
            }
        });

        HorizontalLayout TopSec = new HorizontalLayout(
                ReturnLog
        );
        TopSec.setComponentAlignment(ReturnLog,Alignment.TOP_RIGHT);
        TopSec.setHeight("70px");
        TopSec.setWidth("100%");

        tRegistrationFormLayout RegForm = new tRegistrationFormLayout();
        RegForm.setSizeUndefined();
        VerticalLayout BottomSec = new VerticalLayout(
                RegForm
        );
        //BottomSec.setWidth("100%");
        BottomSec.setSizeFull();
        BottomSec.setMargin(true);
        BottomSec.setComponentAlignment(RegForm,Alignment.TOP_CENTER);

        VerticalSplitPanel ContentPanel = new VerticalSplitPanel();
        ContentPanel.setFirstComponent(TopSec);
        ContentPanel.setSecondComponent(BottomSec);
        ContentPanel.setSplitPosition(70, Unit.PIXELS);
        ContentPanel.setMaxSplitPosition(70, Unit.PIXELS);
        ContentPanel.setMinSplitPosition(70,Unit.PIXELS);

        ContentPanel.setHeight("800px");

        VerticalLayout tRegistrationVeiwContent = new VerticalLayout(
                ContentPanel
        );
        tRegistrationVeiwContent.setSizeFull();


        setCompositionRoot(tRegistrationVeiwContent);
    }
}
