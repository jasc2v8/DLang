module hellodwt;

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

void main()
{
    auto display = new Display;
    auto shell = new Shell;
    shell.setText("Hello World! test2");
    shell.open();

    while (!shell.isDisposed)
        if (!display.readAndDispatch())
            display.sleep();

    display.dispose();
}
