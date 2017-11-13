package com.vaadin;

import com.vaadin.data.validator.IntegerRangeValidator;
import com.vaadin.ui.Button;
import com.vaadin.ui.TextField;
import com.vaadin.ui.VerticalLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 13.11.2017.
 */
public class tTestDiagram extends VerticalLayout {

    final TextField xCoordField = new TextField("X");
    final TextField yCoordField = new TextField("Y");
    final Button button = new Button("move circle");
    final Diagram diagram = new Diagram();
    final List<Integer> coords = new ArrayList<>();

    public tTestDiagram(){
        configureIntegerField(xCoordField);     //not interesting, just adding converter/validator to the textFields
        configureIntegerField(yCoordField);

        button.addClickListener(new Button.ClickListener() {   //ATTENTION! Here we get the coordinates from the textfields and apply them to our Diagram via calling diagram.setCoords()
            @Override
            public void buttonClick(Button.ClickEvent event) {
                if(xCoordField.isValid() && yCoordField.isValid()){
                    coords.clear();
                    coords.add(Integer.parseInt(xCoordField.getValue()));
                    coords.add(Integer.parseInt(yCoordField.getValue()));
                    diagram.setCoords(coords);
                }
            }
        });
        //now we build the layout.
        setSpacing(true);
        addComponent(xCoordField);
        addComponent(yCoordField);
        addComponent(button);
        addComponent(diagram);     //add the diagram like any other vaadin component, cool!
    }

    private void configureIntegerField(final TextField integerField) {
        integerField.setConverter(Integer.class);
        integerField.addValidator(new IntegerRangeValidator("only integer, 0-500", 0, 500));
        integerField.setRequired(true);
        integerField.setImmediate(true);
    }
}
