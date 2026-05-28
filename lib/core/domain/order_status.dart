class OrderStatuses {
  static const draft = 'draft';
  static const confirmed = 'confirmed';
  static const measurementTaken = 'measurement_taken';
  static const cutting = 'cutting';
  static const sewing = 'sewing';
  static const firstFitting = 'first_fitting';
  static const adjustment = 'adjustment';
  static const finalPressing = 'final_pressing';
  static const readyForPickup = 'ready_for_pickup';
  static const delivered = 'delivered';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const delayed = 'delayed';

  static const values = [
    draft,
    confirmed,
    measurementTaken,
    cutting,
    sewing,
    firstFitting,
    adjustment,
    finalPressing,
    readyForPickup,
    delivered,
    completed,
    cancelled,
    delayed,
  ];
}

class OrderPriorities {
  static const low = 'low';
  static const normal = 'normal';
  static const high = 'high';
}

class OrderUrgencyLevels {
  static const normal = 'normal';
  static const urgent = 'urgent';
  static const express = 'express';
}
