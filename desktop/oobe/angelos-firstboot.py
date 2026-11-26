#!/usr/bin/env python3
"""AngelOS 11 First-Boot OOBE — Choose Light or Dark Mode & Windows 11 Desktop Defaults."""

import os
import subprocess
import sys
from pathlib import Path

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont
from PyQt6.QtWidgets import (
    QApplication,
    QButtonGroup,
    QFrame,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QVBoxLayout,
    QWidget,
)

ASSETS_DIR = Path("/opt/angelos/desktop/assets")
LAYOUT_SCRIPT = Path("/usr/local/libexec/angelos-apply-layout")


class ThemeCard(QPushButton):
    def __init__(self, title: str, subtitle: str, bg: str, fg: str, accent: str):
        super().__init__()
        self.setCheckable(True)
        self.setMinimumSize(230, 145)
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(18, 16, 18, 16)

        preview = QFrame()
        preview.setFixedHeight(64)
        preview.setStyleSheet(
            f"background: {bg}; border-radius: 8px; border: 2px solid {accent};"
        )
        layout.addWidget(preview)

        lbl_title = QLabel(title)
        lbl_title.setStyleSheet("font-size: 15px; font-weight: 600;")
        lbl_sub = QLabel(subtitle)
        lbl_sub.setStyleSheet("font-size: 12px; opacity: 0.78;")
        layout.addWidget(lbl_title)
        layout.addWidget(lbl_sub)

        self.setStyleSheet(
            f"""
            QPushButton {{
                text-align: left;
                border-radius: 10px;
                border: 2px solid rgba(128,128,128,0.28);
                background: rgba(128,128,128,0.08);
                color: {fg};
            }}
            QPushButton:checked {{
                border: 2px solid {accent};
                background: rgba(0,120,212,0.16);
            }}
            """
        )


class AngelOSOOBE(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Welcome to AngelOS 11")
        self.setFixedSize(620, 420)
        self.setWindowFlags(Qt.WindowType.Window | Qt.WindowType.WindowStaysOnTopHint)

        root = QVBoxLayout(self)
        root.setContentsMargins(36, 32, 36, 28)
        root.setSpacing(14)

        title = QLabel("Welcome to AngelOS 11")
        title.setFont(QFont("Inter", 22, QFont.Weight.Bold))
        subtitle = QLabel(
            "Choose your default appearance. You can switch between Light and Dark Mode anytime in Settings."
        )
        subtitle.setWordWrap(True)
        subtitle.setStyleSheet("font-size: 13px; color: #A0AAB8;")

        root.addWidget(title)
        root.addWidget(subtitle)
        root.addSpacing(8)

        cards_row = QHBoxLayout()
        cards_row.setSpacing(18)

        self.dark_card = ThemeCard(
            "Dark Mode",
            "Mica Dark & AngelOS Bloom Night",
            "#1A2234",
            "#FFFFFF",
            "#60CDFF",
        )
        self.light_card = ThemeCard(
            "Light Mode",
            "Mica Light & AngelOS Bloom Day",
            "#EBF3FC",
            "#1B1B1B",
            "#0078D4",
        )
        self.dark_card.setChecked(True)

        self.group = QButtonGroup(self)
        self.group.addButton(self.dark_card)
        self.group.addButton(self.light_card)

        cards_row.addWidget(self.dark_card)
        cards_row.addWidget(self.light_card)
        root.addLayout(cards_row)
        root.addStretch(1)

        footer = QHBoxLayout()
        note = QLabel("Windows .exe support & VirtualBox tools ready")
        note.setStyleSheet("font-size: 12px; color: #8A94A6;")
        self.btn_apply = QPushButton("Finish Setup")
        self.btn_apply.setFixedSize(148, 38)
        self.btn_apply.setCursor(Qt.CursorShape.PointingHandCursor)
        self.btn_apply.setStyleSheet(
            """
            QPushButton {
                background-color: #0078D4;
                color: #FFFFFF;
                border-radius: 6px;
                font-size: 14px;
                font-weight: 600;
            }
            QPushButton:hover {
                background-color: #1084DD;
            }
            """
        )
        self.btn_apply.clicked.connect(self.finish_setup)

        footer.addWidget(note)
        footer.addStretch(1)
        footer.addWidget(self.btn_apply)
        root.addLayout(footer)

    def finish_setup(self) -> None:
        mode = "light" if self.light_card.isChecked() else "dark"
        if LAYOUT_SCRIPT.exists():
            subprocess.run(["bash", str(LAYOUT_SCRIPT), mode], check=False)

        config_dir = Path.home() / ".config"
        config_dir.mkdir(parents=True, exist_ok=True)
        (config_dir / "angelos-oobe-done").write_text(mode + "\n", encoding="utf-8")

        autostart_file = config_dir / "autostart" / "angelos-firstboot.desktop"
        if autostart_file.exists():
            autostart_file.unlink()
        self.close()


def main() -> int:
    app = QApplication(sys.argv)
    os.environ.setdefault("QT_QPA_PLATFORM", "wayland")
    win = AngelOSOOBE()
    win.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
