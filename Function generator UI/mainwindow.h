#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "uart_class.h"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

    public:
        MainWindow(QWidget *parent = nullptr);
        ~MainWindow();

    private slots:
        void on_sine_wave_button_clicked();

        void on_square_wave_button_clicked();

        void on_triangle_wave_button_clicked();

        void on_dc_output_button_clicked();

        void on_amplitude_input_returnPressed();

        void on_frequency_input_returnPressed();

        void on_offset_input_returnPressed();

        void on_output_enable_clicked();

        void on_output_voltage_returnPressed();

    private:
        Ui::MainWindow *ui;
        FpgaComm *FPGA_DAC;

        uint16_t voltage_output;
        double amplitude;
        double frequency;
        double offset;
        QString mode;
};
#endif // MAINWINDOW_H
