#!/usr/bin/env python3
"""
OSC ASCII Visualizer for TidalCycles
Receives OSC messages and renders ASCII patterns in the terminal
"""

import curses
import argparse
import math
import time
from oscpy.server import OSCThreadServer

class ASCIIVisualizer:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.height, self.width = stdscr.getmaxyx()
        curses.curs_set(0)  # Hide cursor
        stdscr.nodelay(1)   # Non-blocking input
        stdscr.timeout(16)  # ~60fps refresh rate
        
        # Initialize color pairs if available
        if curses.has_colors():
            curses.start_color()
            curses.init_pair(1, curses.COLOR_CYAN, curses.COLOR_BLACK)
            curses.init_pair(2, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
            curses.init_pair(3, curses.COLOR_YELLOW, curses.COLOR_BLACK)
            curses.init_pair(4, curses.COLOR_GREEN, curses.COLOR_BLACK)
            curses.init_pair(5, curses.COLOR_RED, curses.COLOR_BLACK)
            curses.init_pair(6, curses.COLOR_BLUE, curses.COLOR_BLACK)
            curses.init_pair(7, curses.COLOR_WHITE, curses.COLOR_BLACK)
        
        # State variables for visualization
        self.messages = []
        self.max_messages = 20
        self.particles = []
        self.intensity = 0.0
        self.frequency = 0.0
        self.last_sound = ""
        self.frame = 0
        
        # ASCII character sets for different intensities
        self.chars_low = ['.', '·', ':', '░']
        self.chars_mid = ['▒', '▓', '○', '●']
        self.chars_high = ['█', '▀', '▄', '◆', '◇', '▲', '▼']
        
    def add_message(self, address, *args):
        """Store incoming OSC messages"""
        timestamp = time.strftime("%H:%M:%S")
        # Decode bytes to string if needed
        addr_str = address.decode('utf-8') if isinstance(address, bytes) else address
        msg = f"{timestamp} {addr_str}"
        if args:
            # Decode any bytes in args
            decoded_args = []
            for arg in args:
                if isinstance(arg, bytes):
                    decoded_args.append(arg.decode('utf-8'))
                else:
                    decoded_args.append(arg)
            msg += f" {decoded_args}"
        
        self.messages.append(msg)
        if len(self.messages) > self.max_messages:
            self.messages.pop(0)
        
        # Update visualization parameters based on message
        if b"s" in address or "s" in addr_str or "sound" in addr_str.lower():
            if args:
                sound = args[0]
                if isinstance(sound, bytes):
                    sound = sound.decode('utf-8')
                self.last_sound = str(sound)
        
        # Create particle effect for each message
        self.add_particle()
    
    def add_particle(self):
        """Add a visual particle for effects"""
        import random
        x = random.randint(1, self.width - 2)
        y = random.randint(1, self.height // 2)
        char = random.choice(self.chars_mid + self.chars_high)
        color = random.randint(1, 7)
        velocity = random.uniform(0.5, 2.0)
        self.particles.append({
            'x': x,
            'y': y,
            'char': char,
            'color': color,
            'velocity': velocity,
            'life': 1.0
        })
    
    def update_particles(self):
        """Update particle positions and lifetimes"""
        for particle in self.particles[:]:
            particle['y'] += particle['velocity']
            particle['life'] -= 0.02
            
            if particle['life'] <= 0 or particle['y'] >= self.height - 1:
                self.particles.remove(particle)
    
    def draw_waveform(self, y_offset=3):
        """Draw a waveform visualization"""
        if self.width < 10:
            return
        
        for x in range(1, self.width - 1):
            # Create a sine wave influenced by message activity
            phase = (self.frame * 0.1 + x * 0.2)
            amplitude = len(self.messages) * 0.3
            y = int(math.sin(phase) * amplitude) + y_offset
            
            if 0 < y < self.height - 1:
                char = self.chars_mid[self.frame % len(self.chars_mid)]
                try:
                    self.stdscr.addstr(y, x, char, curses.color_pair(3))
                except curses.error:
                    pass
    
    def draw_bars(self, y_start):
        """Draw vertical bars representing activity"""
        num_bars = min(10, self.width // 4)
        bar_width = (self.width - 2) // num_bars
        
        for i in range(num_bars):
            # Height based on recent activity
            activity = max(0, len(self.messages) - i)
            height = int((activity / self.max_messages) * (self.height - y_start - 2))
            
            x = 1 + i * bar_width
            color_idx = (i % 6) + 1
            
            for h in range(height):
                y = self.height - 2 - h
                if y > y_start:
                    char = '█' if h < height * 0.7 else '▓'
                    try:
                        for dx in range(bar_width - 1):
                            self.stdscr.addstr(y, x + dx, char, curses.color_pair(color_idx))
                    except curses.error:
                        pass
    
    def draw_circle(self, cx, cy, radius):
        """Draw a circle using ASCII characters"""
        for angle in range(0, 360, 10):
            rad = math.radians(angle)
            x = int(cx + radius * math.cos(rad))
            y = int(cy + radius * math.sin(rad) * 0.5)  # 0.5 for aspect ratio
            
            if 0 < x < self.width - 1 and 0 < y < self.height - 1:
                char = self.chars_high[angle % len(self.chars_high)]
                color = ((angle // 60) % 6) + 1
                try:
                    self.stdscr.addstr(y, x, char, curses.color_pair(color))
                except curses.error:
                    pass
    
    def draw(self):
        """Main drawing routine"""
        self.stdscr.clear()
        self.height, self.width = self.stdscr.getmaxyx()
        
        # Draw border
        try:
            self.stdscr.border()
        except curses.error:
            pass
        
        # Title
        title = " OSC ASCII Visualizer for Tidal "
        if len(title) < self.width:
            try:
                self.stdscr.addstr(0, (self.width - len(title)) // 2, title, 
                                 curses.color_pair(2) | curses.A_BOLD)
            except curses.error:
                pass
        
        # Draw visualization based on mode
        mode = (self.frame // 100) % 4
        
        if mode == 0:
            # Waveform mode
            self.draw_waveform(self.height // 3)
        elif mode == 1:
            # Bar graph mode
            self.draw_bars(5)
        elif mode == 2:
            # Circle mode
            if self.messages:
                radius = 5 + len(self.messages) * 0.5
                self.draw_circle(self.width // 2, self.height // 2, int(radius))
        elif mode == 3:
            # Particle mode (drawn separately)
            pass
        
        # Draw particles
        for particle in self.particles:
            x, y = int(particle['x']), int(particle['y'])
            if 0 < x < self.width - 1 and 0 < y < self.height - 1:
                try:
                    alpha = int(particle['life'] * 7)
                    color = min(7, max(1, alpha))
                    self.stdscr.addstr(y, x, particle['char'], curses.color_pair(color))
                except curses.error:
                    pass
        
        # Draw message log at the bottom
        log_start = self.height - min(len(self.messages) + 2, self.height // 3)
        
        try:
            self.stdscr.addstr(log_start, 1, "Recent OSC Messages:", 
                             curses.color_pair(4) | curses.A_BOLD)
        except curses.error:
            pass
        
        for i, msg in enumerate(self.messages[-10:]):
            y = log_start + 1 + i
            if y < self.height - 1:
                display_msg = msg[:self.width - 3]
                try:
                    self.stdscr.addstr(y, 1, display_msg, curses.color_pair(1))
                except curses.error:
                    pass
        
        # Status info
        if self.last_sound:
            status = f" Sound: {self.last_sound} "
            try:
                self.stdscr.addstr(1, 2, status, curses.color_pair(5))
            except curses.error:
                pass
        
        # Frame counter and mode indicator
        mode_names = ["Waveform", "Bars", "Circle", "Particles"]
        info = f" Frame: {self.frame} | Mode: {mode_names[mode]} | Messages: {len(self.messages)} "
        if len(info) < self.width - 2:
            try:
                self.stdscr.addstr(self.height - 1, 2, info, curses.color_pair(6))
            except curses.error:
                pass
        
        self.stdscr.refresh()
    
    def run(self):
        """Main visualization loop"""
        while True:
            self.frame += 1
            self.update_particles()
            self.draw()
            
            # Check for quit
            key = self.stdscr.getch()
            if key == ord('q') or key == 27:  # q or ESC
                break
            
            time.sleep(0.016)  # ~60fps


def main():
    parser = argparse.ArgumentParser(description='OSC ASCII Visualizer for TidalCycles')
    parser.add_argument('--ip', default='0.0.0.0', 
                       help='IP address to listen on (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=6010,
                       help='Port to listen on (default: 6010 - Tidal\'s default)')
    args = parser.parse_args()
    
    def run_visualizer(stdscr):
        visualizer = ASCIIVisualizer(stdscr)
        
        # Create OSC server
        osc = OSCThreadServer(encoding='utf8')
        osc.listen(address=args.ip, port=args.port, default=True)
        
        # Bind a catch-all handler - this will receive ALL OSC messages
        # We use a wildcard pattern by binding to multiple common Tidal addresses
        tidal_addresses = [
            b'/play2',
            b'/dirt/play',
            b'/ctrl',
            b'/play',
        ]
        
        # Create handler that forwards to visualizer
        def osc_handler(*values):
            # The oscpy callback receives values directly
            visualizer.add_message(b'/osc', *values)
        
        # Bind to known Tidal addresses
        for addr in tidal_addresses:
            osc.bind(addr, lambda *vals, address=addr: visualizer.add_message(address, *vals))
        
        # Also create a catch-all by binding common patterns
        # OSCPy doesn't have a true wildcard, so we bind to likely addresses
        for i in range(10):
            osc.bind(f'/orbit/{i}'.encode(), 
                    lambda *vals, n=i: visualizer.add_message(f'/orbit/{n}'.encode(), *vals))
        
        # Run the visualizer
        try:
            visualizer.run()
        finally:
            osc.stop_all()
            osc.terminate_server()
    
    try:
        curses.wrapper(run_visualizer)
    except KeyboardInterrupt:
        print("\nShutting down...")


if __name__ == "__main__":
    main()
