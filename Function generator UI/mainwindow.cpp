#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>
#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QValueAxis>
#include <QTimer>
#include <iostream>

static int sampleIndex = 0;
bool enable = false;
uint16_t previous_voltage_output = 0;
static int timer_counter = 0;
bool square_rising = true;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    //Create FPGA object for receiving values
    FPGA_DAC = new FpgaComm(L"COM5");

    if(!FPGA_DAC->start()){
        QMessageBox::critical(this, "Error", "Failed to open COM port");
    }

    //create series to store voltage values
    QLineSeries *voltageArray = new QLineSeries();

    //create QChart
    QChart *chart = new QChart();

    //set the name for the series, only visible if the legend was enabled
    voltageArray -> setName("Voltage");

    //add the series into the chart
    chart -> addSeries(voltageArray);

    //setting up the pen used to plot the data
    QPen penVoltage(Qt::blue);
    penVoltage.setWidth(2);
    voltageArray -> setPen(penVoltage);

    //Axis
    QValueAxis *axisX = new QValueAxis;
    QValueAxis *axisY = new QValueAxis;

    axisX -> setRange(0, 1000); //only show the last 1000 samples
    axisY -> setRange(0, 3);    //0 to 3V for dac testing purposes

    chart -> setAxisX(axisX, voltageArray);
    chart -> setAxisY(axisY, voltageArray);

    //sending the values to the chart
    ui -> voltagePlot -> setChart(chart);

    // === Timer to continuously update the chart ===
    QTimer* updateTimer = new QTimer(this);
    // connect(updateTimer, &QTimer::timeout, this, [=]() {
    //     voltageArray->append(sampleIndex, voltage_output / 100); //appending the array with the new voltage output from UI

    //     // Keep only last 100 points visible
    //     if (sampleIndex > 1000) {
    //         axisX->setRange(sampleIndex - 1000, sampleIndex);
    //     }

    //     sampleIndex++;

    //     // if(enable) {
    //     //     if(mode == "dc_output"){
    //     //         voltage_output = offset * 100;
    //     //     }
    //     //     else if(mode == "square") {
    //     //         if(timer_counter >= 100){
    //     //             timer_counter = 0; //resetting timer counter after 200 cycles
    //     //             square_rising = !square_rising;
    //     //         }


    //     //         if(square_rising) {
    //     //             voltage_output = (offset + amplitude) * 100;
    //     //         }
    //     //         else {
    //     //             voltage_output = offset * 100;
    //     //         }

    //     //         timer_counter++;
    //     //     }
    //     //     else {
    //     //         timer_counter = 0;
    //     //     }
    //     // }
    //     // else {
    //     //     voltage_output = voltage_output;
    //     // }

    //     // if(voltage_output != previous_voltage_output) {
    //     //     FPGA_DAC -> send_value_to_FPGA(voltage_output);
    //     // }

    //     previous_voltage_output = voltage_output;
    // });

    // updateTimer->start(20); // update every 50 ms (20 Hz)
}

MainWindow::~MainWindow()
{
    FPGA_DAC->stop();
    delete FPGA_DAC;
    delete ui;
}

void MainWindow::on_sine_wave_button_clicked() //sine wave mode selection
{
    mode = "sine";
}


void MainWindow::on_square_wave_button_clicked() //square wave mode selection
{
    mode = "square";
}


void MainWindow::on_triangle_wave_button_clicked() //triangle wave mode selection
{
    mode = "triangle";
}


void MainWindow::on_dc_output_button_clicked() //dc output mode selection
{
    mode = "dc_output";
}


void MainWindow::on_amplitude_input_returnPressed() //amplitude input
{
    amplitude = ui -> amplitude_input -> text().toDouble();
}


void MainWindow::on_frequency_input_returnPressed() //frequency input
{
    frequency = ui -> frequency_input -> text().toDouble();
}


void MainWindow::on_offset_input_returnPressed() //offset input
{
    offset = ui -> offset_input -> text().toDouble();
}


void MainWindow::on_output_enable_clicked()
{
    enable = !enable;
}


void MainWindow::on_output_voltage_returnPressed()
{
    offset = ui -> output_voltage -> text().toDouble();
    FPGA_DAC -> send_value_to_FPGA(offset * 100);
}

