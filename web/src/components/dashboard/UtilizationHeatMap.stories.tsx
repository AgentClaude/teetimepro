import type { Meta, StoryObj } from "@storybook/react";
import { UtilizationHeatMap } from "./UtilizationHeatMap";
import type { UtilizationHeatMapCell, UtilizationHeatMapSummary } from "../../types";

function generateMockCells(days: number): UtilizationHeatMapCell[] {
  const cells: UtilizationHeatMapCell[] = [];
  const baseDate = new Date("2026-03-01");
  const hours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17];

  for (let d = 0; d < days; d++) {
    const date = new Date(baseDate);
    date.setDate(date.getDate() + d);
    const dateStr = date.toISOString().split("T")[0];
    const isWeekend = date.getDay() === 0 || date.getDay() === 6;

    for (const hour of hours) {
      const isMorning = hour >= 7 && hour <= 10;
      const isPeakMorning = hour >= 8 && hour <= 9;

      let baseUtil: number;
      if (isPeakMorning) {
        baseUtil = isWeekend ? 90 : 75;
      } else if (isMorning) {
        baseUtil = isWeekend ? 70 : 55;
      } else if (hour >= 14 && hour <= 16) {
        baseUtil = isWeekend ? 60 : 40;
      } else {
        baseUtil = isWeekend ? 30 : 15;
      }

      // Add some randomness
      const utilization = Math.min(100, Math.max(0, baseUtil + (Math.random() - 0.5) * 20));
      const capacity = hour === 6 || hour === 17 ? 8 : 16;
      const booked = Math.round((utilization / 100) * capacity);

      cells.push({
        date: dateStr,
        hour,
        utilizationPercentage: Math.round(utilization * 10) / 10,
        bookedPlayers: booked,
        totalCapacity: capacity,
        slotCount: capacity / 4,
      });
    }
  }

  return cells;
}

const weekCells = generateMockCells(7);
const monthCells = generateMockCells(28);

const weekSummary: UtilizationHeatMapSummary = {
  overallUtilization: 52.3,
  totalBookedPlayers: 412,
  totalCapacity: 788,
  peakHour: 9,
  peakHourUtilization: 82.5,
  peakDayOfWeek: "Saturday",
  peakDayUtilization: 71.8,
  dateRangeDays: 7,
};

const monthSummary: UtilizationHeatMapSummary = {
  overallUtilization: 48.7,
  totalBookedPlayers: 1534,
  totalCapacity: 3152,
  peakHour: 8,
  peakHourUtilization: 79.2,
  peakDayOfWeek: "Sunday",
  peakDayUtilization: 68.4,
  dateRangeDays: 28,
};

const emptySummary: UtilizationHeatMapSummary = {
  overallUtilization: 0,
  totalBookedPlayers: 0,
  totalCapacity: 0,
  peakHour: null,
  peakHourUtilization: 0,
  peakDayOfWeek: null,
  peakDayUtilization: 0,
  dateRangeDays: 7,
};

const meta: Meta<typeof UtilizationHeatMap> = {
  title: "Dashboard/UtilizationHeatMap",
  component: UtilizationHeatMap,
};

export default meta;
type Story = StoryObj<typeof UtilizationHeatMap>;

export const WeekView: Story = {
  args: {
    cells: weekCells,
    summary: weekSummary,
  },
};

export const MonthView: Story = {
  args: {
    cells: monthCells,
    summary: monthSummary,
  },
};

export const Empty: Story = {
  args: {
    cells: [],
    summary: emptySummary,
  },
};

export const Loading: Story = {
  args: {
    cells: [],
    summary: emptySummary,
    loading: true,
  },
};
