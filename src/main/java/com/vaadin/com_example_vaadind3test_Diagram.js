/**
 * Created by kalistrat on 13.11.2017.
 */
window.com_example_vaadind3test_Diagram  = function () {
    var diagramElement = this.getElement ();
    var diagramFrame = d3.select (diagramElement) .append ("svg: svg"). attr ("width", 500) .attr ("height", 500);
    диаграммаFrame.append ("svg: circle"). attr ("cx", 250) .attr ("cy", 250) .attr ("r", 20) .attr ("fill", "red");

    this.onStateChange = function () {
        var coords = this.getState (). coords;
        d3.selectAll ("circle"). transition (). attr ("cx", parseInt (coords [0]));
        d3.selectAll ("circle"). transition (). delay (500) .attr ("cy", parseInt (coords [1]));
    }
}
