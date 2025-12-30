#ifndef UART_CLASS_H
#define UART_CLASS_H

#include <QObject>
#include <windows.h>
#include <thread>
#include <atomic>
#include <string>

class FpgaComm : public QObject
{
    Q_OBJECT

    public:
        FpgaComm(const std::wstring& portName, DWORD baudRate = 115200, QObject *parent = nullptr);

        ~FpgaComm();

        bool start();
        void stop();
        void send_value_to_FPGA(uint16_t input_value);

    private:
        HANDLE hSerial;
        std::atomic<bool> run_flag;
        std::thread rxThread;
        DWORD baudRate;
        std::wstring portName;

        void listen_fpga();
    };

#endif
