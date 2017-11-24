package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 24.11.2017.
 */
public class tActuatorTaskLayout extends VerticalLayout {

    tActuatorStatesLayout statesLayout;
    Table taskTable;
    IndexedContainer taskTableContainer;
    int iUserDeviceId;
    tTreeContentLayout iParentContentLayout;

    Button AddButton;
    Button DeleteButton;
    Button SaveButton;

    public tActuatorTaskLayout(tActuatorStatesLayout iStatesLayout){
        statesLayout = iStatesLayout;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.CALENDAR_CLOCK.getHtml() + "  " + "Назначенные задания");
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

                int NewItemNum = taskTableContainer.size()+1;

                Item AddedItem = taskTableContainer.addItem(NewItemNum);

                AddedItem.getItemProperty(1).setValue(NewItemNum);

                NativeSelect conditionNameSelect = new NativeSelect();
                conditionNameSelect.setNullSelectionAllowed(false);
                for (int i = 0; i < statesLayout.StatesContainer.size(); i++){
                    conditionNameSelect.addItem(((TextField) statesLayout.StatesContainer
                            .getItem(i+1).getItemProperty(2)
                            .getValue()).getValue());
                }

                conditionNameSelect.select(((TextField) statesLayout.StatesContainer
                        .getItem(1).getItemProperty(2)
                        .getValue()).getValue());

                AddedItem.getItemProperty(2).setValue(conditionNameSelect);

                NativeSelect timIntSelect = new NativeSelect();
                timIntSelect.addItem("секунда");
                timIntSelect.addItem("минута");
                timIntSelect.addItem("час");
                timIntSelect.addItem("сутки");

                timIntSelect.select("минута");
                timIntSelect.setNullSelectionAllowed(false);

                AddedItem.getItemProperty(3).setValue(timIntSelect);
                TextField timeInt = new TextField();
                timeInt.setWidth("50px");
                timeInt.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
                timeInt.setValue("");
                timeInt.setInputPrompt("0");

                AddedItem.getItemProperty(4).setValue(timeInt);

                taskTable.setPageLength(taskTableContainer.size());
                SaveButton.setData(AddedItem);
                SaveButton.setEnabled(true);
                DeleteButton.setEnabled(false);
            }
        });

        DeleteButton = new Button();
        DeleteButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        DeleteButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        DeleteButton.setData(this);

        DeleteButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

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

        taskTable = new Table();
        taskTable.setWidth("100%");

        taskTable.setColumnHeader(1, "№");
        taskTable.setColumnHeader(2, "Наименование<br/>условия");
        taskTable.setColumnHeader(3, "Тип<br/>интервала");
        taskTable.setColumnHeader(4, "Значение<br/>интервала");

        taskTableContainer = new IndexedContainer();
        taskTableContainer.addContainerProperty(1, Integer.class, null);
        taskTableContainer.addContainerProperty(2, NativeSelect.class, null);
        taskTableContainer.addContainerProperty(3, NativeSelect.class, null);
        taskTableContainer.addContainerProperty(4, TextField.class, null);

//        statesLayout.setListener(new addDeleteListener() {
//            @Override
//            public void afterDelete(String itemName) {
//
//                for (int j=0; j < taskTableContainer.size(); j++) {
//                    NativeSelect conditionNameSelect =
//                            (NativeSelect) taskTableContainer.getItem(j+1)
//                                    .getItemProperty(2).getValue();
//                    conditionNameSelect.removeAllItems();
//
//                    for (int i = 0; i < statesLayout.StatesContainer.size(); i++) {
//                        conditionNameSelect.addItem(((TextField) statesLayout.StatesContainer
//                                .getItem(i + 1).getItemProperty(2)
//                                .getValue()).getValue());
//                    }
//
//                    conditionNameSelect.select(((TextField) statesLayout.StatesContainer
//                            .getItem(1).getItemProperty(2)
//                            .getValue()).getValue());
//                }
//            }
//
//            @Override
//            public void afterAdd(String itemName) {
//                for (int j=0; j < taskTableContainer.size(); j++) {
//                    NativeSelect conditionNameSelect =
//                            (NativeSelect) taskTableContainer.getItem(j+1)
//                                    .getItemProperty(2).getValue();
//                    conditionNameSelect.removeAllItems();
//
//                    for (int i = 0; i < statesLayout.StatesContainer.size(); i++) {
//                        conditionNameSelect.addItem(((TextField) statesLayout.StatesContainer
//                                .getItem(i + 1).getItemProperty(2)
//                                .getValue()).getValue());
//                    }
//
//                    conditionNameSelect.select(((TextField) statesLayout.StatesContainer
//                            .getItem(1).getItemProperty(2)
//                            .getValue()).getValue());
//                }
//            }
//        });

        setTaskTableContainer();

        taskTable.setContainerDataSource(taskTableContainer);


        taskTable.setPageLength(taskTableContainer.size());



        taskTable.addStyleName(ValoTheme.TABLE_COMPACT);
        taskTable.addStyleName(ValoTheme.TABLE_SMALL);
        taskTable.addStyleName("TableRow");


        taskTable.setSelectable(true);

        VerticalLayout taskTableLayout = new VerticalLayout(
                taskTable
        );
        taskTableLayout.setWidth("100%");
        taskTableLayout.setHeightUndefined();
        taskTableLayout.setComponentAlignment(taskTable,Alignment.MIDDLE_CENTER);

        VerticalLayout ContentLayout = new VerticalLayout(
                HeaderLayout
                ,taskTableLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);
    }

    public void setTaskTableContainer(){

    }
}
